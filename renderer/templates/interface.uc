{%
	let has_downstream_relays = false;

	// Skip interfaces previously marked as conflicting.
	if (interface.conflicting) {
		warn("Skipping conflicting interface declaration");

		return;
	}

	// store our index
	interface.index = substr(location, rindex(location, "/") + 1);

	// Check this interface for role/vlan uniqueness...
	let this_vid = interface.vlan ? interface.vlan.id : 1;

	for (let other_interface in state.interfaces) {
		if (other_interface == interface)
			continue;

		if (!other_interface.ethernet && length(interface.ssids) == 1)
			continue;

		let other_vid = other_interface.vlan ? other_interface.vlan.id : '';

		if (interface.role === other_interface.role && this_vid === other_vid) {
			warn("Multiple interfaces with same role and VLAN ID defined, ignoring conflicting interface");
			other_interface.conflicting = true;
		}

		if (other_interface.role == 'downstream' &&
		    other_interface.ipv6 &&
		    other_interface.ipv6.dhcpv6 &&
		    other_interface.ipv6.dhcpv6.mode == 'relay')
		    has_downstream_relays = true;
	}

	// check if a downstream interface with a vlan has a matching upstream interface
	if (interface.vlan && interface.role == "downstream" && index(vlans, this_vid) < 0) {
		warn("Trying to create a downstream interface with a VLAN ID, without matching upstream interface.");
		return;
	}

	// resolve auto prefixes
	if (interface.ipv4 && interface.ipv4.subnet) {
		try {
			interface.ipv4.subnet = ipcalc.generate_prefix(state, interface.ipv4.subnet, false);
		}
		catch (e) {
			warn("Unable to allocate a suitable IPv4 prefix: %s, ignoring interface", e);
			return;
		}
	}

	if (interface.ipv6 && interface.ipv6.subnet) {
		try {
			interface.ipv6.subnet = ipcalc.generate_prefix(state, interface.ipv6.subnet, true);
		}
		catch (e) {
			warn("Unable to allocate a suitable IPv6 prefix: %s, ignoring interface", e);
			return;
		}
	}

	// Captive Portal is only supported on downstream interfaces
	if (interface.captive && interface.role != 'downstream') {
		warn("Trying to create a Cpative Portal on a none downstream interface.");
		return;
	}

	// Gather related BSS modes and ethernet ports.
	let bss_modes = map(interface.ssids, ssid => ssid.bss_mode);
	let eth_ports = ethernet.lookup_by_interface_spec(interface);

	// If at least one station mode SSID is part of this interface then we must
	// not bridge at all. Having any other SSID or any number of matching ethernet
	// ports in such a case is a semantic error.
	if ('sta' in bss_modes && (length(eth_ports) > 0 || length(bss_modes) > 1)) {
		warn("Station mode SSIDs cannot be bridged with ethernet ports or other SSIDs, ignoring interface");

		return;
	}

	// store the VLAN id assigned to this interface
	push(vlans, this_vid);

	// Compute unique logical name and netdev name to use
	let name = ethernet.calculate_name(interface);
	let bridgedev = 'up';
	if (capab.platform != "switch" && interface.role == "downstream")
		bridgedev = 'down';
	let netdev = bridgedev + '.' + this_vid;

	// Determine the IPv4 and IPv6 configuration modes and figure out if we
	// can set them both in a single interface (automatic) or whether we need
	// two logical interfaces due to different protocols.
	let ipv4_mode = interface.ipv4 ? interface.ipv4.addressing : 'none';
	let ipv6_mode = interface.ipv6 ? interface.ipv6.addressing : 'none';

	// If no metric is defined explicitly, any upstream interfaces will default
	// to 5 and downstream interfaces will default to 10
	if (!interface.metric && interface.role == "upstream")
		interface.metric = 5;
	if (!interface.metric && interface.role == "downstream")
		interface.metric = 10;

	// If this interface is a tunnel, we need to create the interface
	// in a different way
	let tunnel_proto = interface.tunnel ? interface.tunnel.proto : '';

	//
	// Create the actual UCI sections
	//

	// Some tunnels do not need the normal bridge-vlan setup
	if (tunnel_proto in [ "vxlan", 'gre' ]) {
		include("interface/" + tunnel_proto + ".uc", { interface, name, location, netdev, ipv4_mode, ipv6_mode });
		return;
	}

	// Mesh requires the 2 additional interface sections
	if (tunnel_proto == "mesh")
		include("interface/mesh.uc", { name });

	if (!interface.ethernet && length(interface.ssids) == 1 && !tunnel_proto)
		// interfaces with a single ssid and no tunnel do not need a bridge
		netdev = ''
	else
		// anything else requires a bridge-vlan
		include("interface/bridge-vlan.uc", { interface, name, eth_ports, this_vid, bridgedev });

	include("interface/common.uc", {
		name, this_vid, netdev,
		ipv4_mode, ipv4: interface.ipv4 || {},
		ipv6_mode, ipv6: interface.ipv6 || {}
	});

	include('interface/firewall.uc', { name, ipv4_mode, ipv6_mode });

	if (interface.ipv4 || interface.ipv6) {
		include('interface/dhcp.uc', {
			ipv4: interface.ipv4 || {},
			ipv6: interface.ipv6 || {},
			has_downstream_relays
		});
	}

	let count = 0;
	for (let i, ssid in interface.ssids) {
		let modes = (ssid.bss_mode == "wds-repeater") ?
			[ "wds-sta", "wds-ap" ] : [ ssid.bss_mode ];
		for (let mode in modes) {
			include('interface/ssid.uc', {
				location: location + '/ssids/' + i,
				ssid: { ...ssid, bss_mode: mode },
				count: count++,
				name
			});
		}
	}

	if (interface.captive)
		include('interface/captive.uc', { netdev });
%}

{%
	let math = require("math");

	// Skip interfaces previously marked as conflicting.
	if (interface.conflicting) {
		warn("Skipping conflicting interface declaration");

		return;
	}

	// Check this interface for role/vlan uniqueness...
	let this_vid = interface.vlan ? interface.vlan.id : 1;

	for (let other_interface in state.interfaces) {
		if (other_interface == interface)
			continue;

		let other_vid = other_interface.vlan ? other_interface.vlan.id : '';

		if (interface.role === other_interface.role && this_vid === other_vid) {
			warn("Multiple interfaces with same role and VLAN ID defined, ignoring conflicting interface");
			other_interface.conflicting = true;
		}
	}

	// check if a downstream interface with a vlan has a matching upstream interface
	if (interface.vlan && interface.role == "downstream" && index(vlans, this_vid) < 0) {
		warn("Trying to create a downstream interface with a VLAN ID, without matching upstream interface.");
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
	if (interface.role == "downstream")
		bridgedev = 'down';
	let netdev = bridgedev + '.' + this_vid;

	// Determine the IPv4 and IPv6 configuration modes and figure out if we
	// can set them both in a single interface (dualstack) or whether we need
	// two logical interfaces due to different protocols.
	let ipv4_mode = interface.ipv4 ? interface.ipv4.addressing : 'none';
	let ipv6_mode = interface.ipv6 ? interface.ipv6.addressing : 'none';
	let use_dualstack = (
		(ipv4_mode == 'none') || (ipv6_mode == 'none') ||
		(ipv4_mode == 'static' && ipv6_mode == 'static')
	);

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
	if (tunnel_proto in [ "vxlan" ]) {
		include("interface/" + tunnel_proto + ".uc", { name });
		return;
	}

	// Mesh requires the 2 additional interface sections
	if (tunnel_proto == "mesh")
		include("interface/mesh.uc", { name });

	// All none L2/3 tunnel require a vlan inside their bridge
	include("interface/bridge-vlan.uc", { eth_ports, this_vid, bridgedev });

	if (use_dualstack) {
		include("interface/dualstack.uc", { interface, name, this_vid, location, netdev, ipv4_mode, ipv6_mode });
	} else {
		if (ipv4_mode != 'none')
			include("interface/ipv4.uc", { interface, name, this_vid, location, netdev });
		if (ipv6_mode != 'none')
			include("interface/ipv6.uc", { interface, name, this_vid, location, netdev });
	}

	include('interface/firewall.uc');

	if (interface.ipv4)
		include('interface/dhcp.uc');

	for (let i, ssid in interface.ssids) {
		include('interface/ssid.uc', {
			location: location + '/ssids/' + i,
			ssid,
			name
		});
	}
%}

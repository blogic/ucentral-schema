{%
	// Skip interfaces previously marked as conflicting.
	if (interface.conflicting) {
		warn("Skipping conflicting interface declaration");

		return;
	}

	// Check this interface for role/vlan uniqueness...
	let this_vid = interface.vlan ? interface.vlan.id : '';

	if (!this_vid) {
		if (interface.role == 'upstream')
			this_vid = 2;
		else
			this_vid = 1;
	}

	for (let other_interface in state.interfaces) {
		if (other_interface == interface)
			continue;

		let other_vid = other_interface.vlan ? other_interface.vlan.id : '';

		if (interface.role === other_interface.role && this_vid === other_vid) {
			warn("Multiple interfaces with same role and VLAN ID defined, ignoring conflicting interface");
			other_interface.conflicting = true;
		}
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

	// Compute unique logical name and netdev name to use
	let name = ethernet.calculate_names(interface);
	let bridgedev = 'bridge';
	let netdev = '';

	// If this interface enables host isolation, we need to turn it into a
	// dedicated isolated netdev...
	if (interface.isolate_hosts) {
		// If there are any ethernet ports or multiple SSIDs participating,
		// we need to spawn a new bridge interface.
		if (length(eth_ports) > 0 || length(bss_modes) > 1)
			netdev = 'br-' + name;
	}
	// ... upstream interfaces with a vlan require the @upstream syntax
	else if (interface.role == 'upstream' && interface.vlan) {
		netdev = "@upstream." + this_vid;
	}
	// ... otherwise we program a VLAN on top of the global bridge.
	else {
		netdev = bridgedev + '.' + this_vid;
	}

	// Determine the IPv4 and IPv6 configuration modes and figure out if we
	// can set them both in a single interface (dualstack) or whether we need
	// two logical interfaces due to different protocols.
	let ipv4_mode = interface.ipv4 ? interface.ipv4.addressing : 'none';
	let ipv6_mode = interface.ipv6 ? interface.ipv6.addressing : 'none';
	let use_dualstack = (
		(ipv4_mode == 'none') || (ipv6_mode == 'none') ||
		(ipv4_mode == 'static' && ipv6_mode == 'static')
	);
%}

# Network configuration
add network interface
set networ.@interface[-1].ifname='lo'
set networ.@interface[-1].proto='static'
set networ.@interface[-1].ipaddr='127.0.0.1'
set networ.@interface[-1].netmask='255.0.0.0'

add network device
set network.@device[-1].name=bridge
set network.@device[-1].type=bridge

{% if (interface.isolate_hosts && netdev): %}
set network.{{ name }}_dev=device
set network.{{ name }}_dev.type=bridge
set network.{{ name }}_dev.name={{ netdev }}
{%  for (let i, port in eth_ports): %}
{{ i ? 'add_list' : 'set' }} network.{{ name }}_dev.ifname={{ port }}
{%  endfor %}
{% elif (!interface.isolate_hosts): %}
set network.{{ name }}_vlan=bridge-vlan
set network.{{ name }}_vlan.device={{ bridgedev }}
set network.{{ name }}_vlan.vlan={{ this_vid }}
{%  for (let i, port in eth_ports): %}
{{ i ? 'add_list' : 'set' }} network.{{ name }}_vlan.ports={{ port }}{{ ((interface.role == 'upstream') && interface.vlan) ? ':t' : '' }}
{%  endfor %}
{% endif %}

{% if (use_dualstack): %}
set network.{{ name }}=interface
set network.{{ name }}.ucentral_name={{ s(interface.name) }}
set network.{{ name }}.ifname={{ netdev }}
set network.{{ name }}.metric={{ interface.metric }}
{%  if (ipv4_mode == 'static'): %}
set network.{{ name }}.proto=static
set network.{{ name }}.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv4.subnet) }}
{%  elif (ipv6_mode == 'static'): %}
set network.{{ name }}.proto=static
set network.{{ name }}.ip6addr={{ ipcalc.generate_prefix(state, interface.ipv6.subnet) }}
{%  elif (ipv4_mode == 'dynamic'): %}
set network.{{ name }}.proto=dhcp
{%   for (let dns in interface.ipv4.use_dns): %}
list_add network.{{ name }}.dns={{ dns }}
{%   endfor %}
set network.{{ name }}.peerdns={{ b(!length(interface.ipv4.use_dns)) }}
{%  else %}
set network.{{ name }}.proto=dhcpv6
{%  endif %}
{% if (interface.role == 'upstream'): %}
set network.{{ name }}.ip4table={{ this_vid }}
set network.{{ name }}.ip6table={{ this_vid }}
{%  endif %}
{% else %}
{%  if (ipv4_mode != 'none'): %}
set network.{{ name }}_4=interface
set network.{{ name }}_4.ucentral_name={{ s(interface.name) }}
set network.{{ name }}_4.ifname={{ netdev }}
set network.{{ name }}_4.metric={{ interface.metric }}
{%   if (interface.role == 'upstream'): %}
set network.{{ name }}_4.ip4table={{ this_vid }}
{%   endif %}
{%   if (ipv4_mode == 'static'): %}
set network.{{ name }}_4.proto=static
set network.{{ name }}_4.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv4.subnet) }}
{%   else %}
set network.{{ name }}_4.proto=dhcp
{%   endif %}
{%  endif %}
{%  if (ipv6_mode != 'none'): %}
set network.{{ name }}_6=interface
set network.{{ name }}_6.ucentral_name={{ s(interface.name) }}
set network.{{ name }}_6.ifname={{ netdev }}
set network.{{ name }}_6.metric={{ interface.metric }}
{%   if (interface.role == 'upstream'): %}
set network.{{ name }}_6.ip6table={{ this_vid }}
{%   endif %}
{%   if (ipv6_mode == 'static'): %}
set network.{{ name }}_6.proto=static
set network.{{ name }}_6.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv6.subnet) }}
{%   else %}
set network.{{ name }}_6.proto=dhcp
{%   endif %}
{%  endif %}
{% endif %}

{% if (use_dualstack && interface.role == "downstream" && interface.vlan): %}
add network rule
set network.@rule[-1].in={{ name }}
set network.@rule[-1].lookup={{ this_vid }}
{% endif %}

{%
	include('interface/firewall.uc', {
		interface,
		networks: use_dualstack ? [ name ] : [ name + '_4', name + '_6' ]
	});

	if (interface.ipv4)
		include('interface/dhcp.uc', {
			interface,
			name: use_dualstack ?  name : name + '_4'
		});

	for (let i, ssid in interface.ssids) {
		include('ssid.uc', {
			location: location + '/ssids/' + i,
			ssid,
			interface,
			networks: use_dualstack ? [ name ] : [ name + '_4', name + '_6' ]
		});
	}
%}

{% if (interface.broad_band.protocol == 'wwan'): %}
{%
function match_pdptype() {
	let pdptypes = {
		'ipv4': 'ip',
		'ipv6': 'ipv6',
		'dual-stack': 'ipv4v6'
	};
	return pdptypes[interface.broad_band.packet_data_protocol];
}

function match_authtype() {
	if (interface.broad_band.authentication_type == 'papchap')
		return 'both';
	return interface.broad_band.authentication_type;
}

let dual = interface.broad_band.packet_data_protocol == "dual-stack";
let ipv4 = interface.broad_band.packet_data_protocol == "ipv4" || dual;
let ipv6 = interface.broad_band.packet_data_protocol == "ipv6" || dual;
%}

set network.{{ name }}=interface
set network.{{ name }}.ucentral_name={{ s(interface.name) }}
set network.{{ name }}.ucentral_path={{ s(location) }}
set network.{{ name }}.proto={{ s(interface.broad_band.modem_type) }}
set network.{{ name }}.pincode={{ s(interface.broad_band.pin_code) }}
set network.{{ name }}.apn={{ s(interface.broad_band.access_point_name) }}
set network.{{ name }}.device='/dev/cdc-wdm0'
set network.{{ name }}.pdptype={{ s(match_pdptype()) }}
set network.{{ name }}.auth={{ s(match_authtype()) }}
set network.{{ name }}.username={{ s(interface.broad_band.username) }}
set network.{{ name }}.password={{ s(interface.broad_band.password) }}
{% endif %}

{% if (interface.broad_band.protocol == 'pppoe'): %}
{%   let ipv4 = true, ipv6 = true;%}

set network.{{ name }}=interface
set network.{{ name }}.ucentral_name={{ s(interface.name) }}
set network.{{ name }}.ucentral_path={{ s(location) }}
set network.{{ name }}.ifname={{ s(eth_ports[0]) }}
set network.{{ name }}.proto='pppoe'
set network.{{ name }}.username={{ s(interface.broad_band.username) }}
set network.{{ name }}.password={{ s(interface.broad_band.password) }}
set network.{{ name }}.timeout={{ s(interface.broad_band.timeout) }}
{% endif %}


{%
if (ipv4 || ipv6)
	include('firewall.uc', { name, ipv4, ipv6 });
%}

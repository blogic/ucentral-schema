{%
function match_pdptype() {
	let pdptypes = {
		'ipv4': 'ip',
		'ipv6': 'ipv6',
		'dual-stack': 'ipv4v6'
	};
	return pdptypes[interface.wwan.packet_data_protocol];
}

function match_authtype() {
	if (interface.wwan.authentication_type == 'papchap')
		return 'both';
	return interface.wwan.authentication_type;
}
%}


set network.{{ name }}=interface
set network.{{ name }}.ucentral_name={{ s(interface.name) }}
set network.{{ name }}.ucentral_path={{ s(location) }}
set network.{{ name }}.proto={{ s(interface.wwan.protocol) }}
set network.{{ name }}.pincode={{ s(interface.wwan.pin_code) }}
set network.{{ name }}.apn={{ s(interface.wwan.access_point_name) }}
set network.{{ name }}.device='/dev/cdc-wdm0'
set network.{{ name }}.pdptype={{ s(match_pdptype()) }}
set network.{{ name }}.auth={{ s(match_authtype()) }}
set network.{{ name }}.username={{ s(interface.wwan.username) }}
set network.{{ name }}.password={{ s(interface.wwan.password) }}

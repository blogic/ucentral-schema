{% let interfaces = services.lookup_interfaces("dhcp-snooping") %}

# DHCP Snooping configuration
set event.dhcp=event
set event.dhcp.type=dhcp
set event.dhcp.filter='*'
{% for (let n, filter in dhcp_snooping.filters): %}
{{ n ? 'add_list' : 'set' }} event.dhcp.filter={{ filter }}
{% endfor %}

set dhcpsnooping.@snooping[-1].enable=1
{% for (let interface in interfaces): %}
{%	let name = ethernet.calculate_name(interface) %}
add_list dhcpsnooping.@snooping[-1].network={{ s(name) }}
{% endfor %}

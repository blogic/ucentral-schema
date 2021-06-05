{% let interfaces = services.lookup_interfaces("dhcp-snooping") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("dhcpsnoop", enable) %}
{% if (!enable) return %}

# DHCP Snooping configuration

set event.dhcp=event
set event.dhcp.type=dhcp
set event.dhcp.filter='*'
{% for (let n, filter in dhcp_snooping.filters): %}
{{ n ? 'add_list' : 'set' }} event.dhcp.filter={{ filter }}
{% endfor %}

set dhcpsnoop.@snooping[-1].enable=1
{% for (let interface in interfaces): %}
{%	let name = ethernet.calculate_name(interface) %}
add_list dhcpsnoop.@snooping[-1].network={{ s(name) }}
{% endfor %}

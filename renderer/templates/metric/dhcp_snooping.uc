{% let interfaces = services.lookup_interfaces("dhcp-snooping") %}

# DHCP Snooping configuration
{% for (let filter in dhcp_snooping.filters): %}
add_list event.dhcp.filter={{ filter }}
{% endfor %}

{% for (let interface in interfaces): %}
{%	let name = ethernet.calculate_name(interface) %}
set dhcpsnooping.@snooping[0].{{ name }}=1
{% endfor %}

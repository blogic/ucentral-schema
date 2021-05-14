
# DHCP Snooping configuration
delete event.dhcp.filter
{% for (let filter in dhcp_snooping.filters): %}
add_list event.dhcp.filter={{ filter }}
{% endfor %}

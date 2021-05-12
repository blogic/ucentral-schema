
# DHCP Snooping configuration
delete event.dhcp.filter
{% for (let filter in dhcp_snooping.filters): %}
list_add event.dhcp.filter={{ filter }}
{% endfor %}

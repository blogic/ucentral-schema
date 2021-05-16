{% let name = ethernet.calculate_name(interface) %}
{% let dhcp = interface.ipv4.dhcp || { ignore: 1 } %}
set dhcp.{{ name }}=dhcp
set dhcp.{{ name }}.interface={{ s(name) }}
set dhcp.{{ name }}.start={{ dhcp.lease_first }}
set dhcp.{{ name }}.limit={{ dhcp.lease_count }}
set dhcp.{{ name }}.leasetime={{ dhcp.lease_time }}
set dhcp.{{ name }}.ignore={{ b(dhcp.ignore) }}
{% for (let lease in interface.ipv4.dhcp_leases): %}
add dhcp host
set dhcp.@host[-1].hostname={{ lease.hostname }}
set dhcp.@host[-1].mac={{ lease.macaddr }}
set dhcp.@host[-1].ip={{ lease.static_lease_offset }}
set dhcp.@host[-1].leasetime={{ lease.lease_time }}
set dhcp.@host[-1].instance={{ s(name) }}
{% endfor %}

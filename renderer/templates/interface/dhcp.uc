
{% let dhcp = interface.ipv4.dhcp || { ignore: 1 } %}
add dhcp dhcp
set dhcp.@dhcp[-1].interface={{ s(name) }}
set dhcp.@dhcp[-1].start={{ dhcp.lease_first }}
set dhcp.@dhcp[-1].limit={{ dhcp.lease_count }}
set dhcp.@dhcp[-1].leasetime={{ dhcp.lease_time }}
set dhcp.@dhcp[-1].ignore={{ b(dhcp.ignore) }}
{% for (let lease in interface.ipv4.dhcp_leases): %}
add dhcp host
set dhcp.@host[-1].hostname={{ lease.hostname }}
set dhcp.@host[-1].mac={{ lease.macaddr }}
set dhcp.@host[-1].ip={{ lease.static_lease_offset }}
set dhcp.@host[-1].leasetime={{ lease.lease_time }}
set dhcp.@host[-1].instance={{ s(name) }}
{% endfor %}

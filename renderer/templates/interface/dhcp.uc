{% let name = ethernet.calculate_ipv4_name(interface) %}
{% let dhcp = ipv4.dhcp || { ignore: 1 } %}
{% let dhcpv6 = ipv6.dhcpv6 || { ignore: 1 } %}
set dhcp.{{ name }}=dhcp
set dhcp.{{ name }}.interface={{ s(name) }}
set dhcp.{{ name }}.start={{ dhcp.lease_first }}
set dhcp.{{ name }}.limit={{ dhcp.lease_count }}
set dhcp.{{ name }}.leasetime={{ dhcp.lease_time }}
set dhcp.{{ name }}.ignore={{ b(dhcp.ignore) }}
{% if (interface.role != 'upstream'): %}
{%  if (dhcpv6.mode == 'hybrid'): %}
set dhcp.{{ name }}.ra=server
set dhcp.{{ name }}.dhcpv6=server
set dhcp.{{ name }}.ndp=disabled
{%  elif (dhcpv6.mode == 'stateful'): %}
set dhcp.{{ name }}.ra=disabled
set dhcp.{{ name }}.dhcpv6=server
set dhcp.{{ name }}.ndp=disabled
{%  elif (dhcpv6.mode == 'stateless'): %}
set dhcp.{{ name }}.ra=server
set dhcp.{{ name }}.dhcpv6=disabled
set dhcp.{{ name }}.ndp=disabled
{%  elif (dhcpv6.mode == 'relay'): %}
set dhcp.{{ name }}.ra=relay
set dhcp.{{ name }}.dhcpv6=relay
set dhcp.{{ name }}.ndp=relay
{%  else %}
set dhcp.{{ name }}.ra=disabled
set dhcp.{{ name }}.dhcpv6=disabled
set dhcp.{{ name }}.ndp=disabled
{%  endif %}
{% else %}
set dhcp.{{ name }}.master={{ b(has_downstream_relays) }}
set dhcp.{{ name }}.ra={{ has_downstream_relays ? 'relay' : 'disabled' }}
set dhcp.{{ name }}.dhcpv6={{ has_downstream_relays ? 'relay' : 'disabled' }}
set dhcp.{{ name }}.ndp={{ has_downstream_relays ? 'relay' : 'disabled' }}
{% endif %}
{% for (let lease in interface.ipv4.dhcp_leases): %}
add dhcp host
set dhcp.@host[-1].hostname={{ lease.hostname }}
set dhcp.@host[-1].mac={{ lease.macaddr }}
set dhcp.@host[-1].ip={{ lease.static_lease_offset }}
set dhcp.@host[-1].leasetime={{ lease.lease_time }}
set dhcp.@host[-1].instance={{ s(name) }}
{% endfor %}

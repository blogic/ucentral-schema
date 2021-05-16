set network.{{name}}=interface_6
set network.{{ name }}_6.ucentral_name={{ s(interface.name) }}
set network.{{ name }}_6.ucentral_path={{ s(location) }}
set network.{{ name }}_6.ifname={{ netdev }}
set network.{{ name }}_6.metric={{ interface.metric }}
{% if (interface.role == 'upstream' && interface.vlan): %}
set network.{{ name }}_6.ip6table={{ this_vid }}
{%   endif %}
{%  if (ipv6_mode == 'static'): %}
set network.{{ name }}_6.proto=static
set network.{{ name }}_6.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv6.subnet) }}
{%  else %}
set network.{{ name }}_6.proto=dhcp
{%  endif %}
{% endif %}

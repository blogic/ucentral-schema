set network.{{name}}=interface_4
set network.{{ name }}_4.ucentral_name={{ s(interface.name) }}
set network.{{ name }}_4.ucentral_path={{ s(location) }}
set network.{{ name }}_4.ifname={{ netdev }}
set network.{{ name }}_4.metric={{ interface.metric }}
{% if (interface.role == 'upstream' && interface.vlan): %}
set network.{{ name }}_4.ip4table={{ this_vid }}
{%   endif %}
{%  if (ipv4_mode == 'static'): %}
set network.{{ name }}_4.proto=static
set network.{{ name }}_4.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv4.subnet) }}
{%  else %}
set network.{{ name }}_4.proto=dhcp
{%  endif %}
{% endif %}

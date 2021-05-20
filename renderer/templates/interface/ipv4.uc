{% if (interface.role == 'upstream' && interface.vlan): %}
set network.{{ name }}.ip4table={{ this_vid }}
{% endif %}
{% if (ipv4_mode == 'static'): %}
set network.{{ name }}.ipaddr={{ ipcalc.generate_prefix(state, ipv4.subnet, false) }}
{% else %}
set network.{{ name }}.peerdns={{ b(!length(ipv4.use_dns)) }}
{%  for (let dns in ipv4.use_dns): %}
add_list network.{{ name }}.dns={{ dns }}
{%  endfor %}
{% endif %}

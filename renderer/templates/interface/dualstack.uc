set network.{{ name }}=interface
set network.{{ name }}.ucentral_name={{ s(interface.name) }}
set network.{{ name }}.ucentral_path={{ s(location) }}
set network.{{ name }}.ifname={{ netdev }}
set network.{{ name }}.metric={{ interface.metric }}
{%  if (ipv4_mode == 'none' && ipv6_mode == 'none'): %}
set network.{{ name }}.proto=none
{%  elif (ipv4_mode == 'static'): %}
set network.{{ name }}.proto=static
set network.{{ name }}.ipaddr={{ ipcalc.generate_prefix(state, interface.ipv4.subnet) }}
{%  elif (ipv6_mode == 'static'): %}
set network.{{ name }}.proto=static
set network.{{ name }}.ip6addr={{ ipcalc.generate_prefix(state, interface.ipv6.subnet) }}
{%  elif (ipv4_mode == 'dynamic'): %}
set network.{{ name }}.proto=dhcp
{%   for (let dns in interface.ipv4.use_dns): %}
add_list network.{{ name }}.dns={{ dns }}
{%   endfor %}
set network.{{ name }}.peerdns={{ b(!length(interface.ipv4.use_dns)) }}
{%  else %}
set network.{{ name }}.proto=dhcpv6
{%  endif %}
{% if (interface.role == 'upstream' && interface.vlan): %}
set network.{{ name }}.ip4table={{ this_vid }}
set network.{{ name }}.ip6table={{ this_vid }}
{%  endif %}
{% if (interface.role == "downstream" && interface.vlan): %}
add network rule
set network.@rule[-1].in={{ name }}
set network.@rule[-1].lookup={{ interface.vlan.id }}
{% endif %}

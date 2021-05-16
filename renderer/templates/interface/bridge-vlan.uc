add network bridge-vlan
set network.@bridge-vlan[-1].device={{ bridgedev }}
set network.@bridge-vlan[-1].vlan={{ this_vid }}
{%  for (let port in eth_ports): %}
add_list network.@bridge-vlan[-1].ports={{ port }}{{ ((interface.role == 'upstream') && interface.vlan) ? ':t' : '' }}
{%  endfor %}

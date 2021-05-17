add network bridge-vlan
set network.@bridge-vlan[-1].device={{ bridgedev }}
set network.@bridge-vlan[-1].vlan={{ this_vid }}
{%  for (let port in eth_ports): %}
add_list network.@bridge-vlan[-1].ports={{ port }}{{ ((interface.role == 'upstream') && interface.vlan) ? ':t' : '' }}
{%  endfor %}
{% if (interface.tunnel && interface.tunnel.proto == "mesh"): %}
add_list network.@bridge-vlan[-1].ports={{ name }}_bat
{% endif %}
{% if (interface.bridge): %}
network.@bridge-vlan[-1].txqueuelen={{ interface.bridge.tx_queue_len }}
network.@bridge-vlan[-1].isolate={{interface.bridge.isolate_ports }}
network.@bridge-vlan[-1].mtu={{ interface.bridge.mtu }}
{% endif %}

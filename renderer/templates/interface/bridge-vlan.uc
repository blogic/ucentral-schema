add network bridge-vlan
set network.@bridge-vlan[-1].device={{ bridgedev }}
set network.@bridge-vlan[-1].vlan={{ this_vid }}
{%  for (let port in eth_ports): %}
add_list network.@bridge-vlan[-1].ports={{ port }}{{ ((interface.role == 'upstream') && ethernet.has_vlan(interface)) ? ':t' : '' }}
{%  endfor %}
{% if (interface.tunnel && interface.tunnel.proto == "mesh"): %}
add_list network.@bridge-vlan[-1].ports={{ name }}_bat
{% endif %}
{% if (interface.bridge): %}
network.@bridge-vlan[-1].txqueuelen={{ interface.bridge.tx_queue_len }}
network.@bridge-vlan[-1].isolate={{interface.bridge.isolate_ports }}
network.@bridge-vlan[-1].mtu={{ interface.bridge.mtu }}
{% endif %}

add network device
set network.@device[-1].type=8021q
set network.@device[-1].name={{ name }}
set network.@device[-1].ifname={{ bridgedev }}
set network.@device[-1].vid={{ this_vid }}

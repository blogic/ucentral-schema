add_list network.@bridge-vlan[-1].ports={{ name }}_bat

set network.{{ name }}_bat=interface
set network.{{ name }}_bat.proto=batadv
set network.{{ name }}_bat.multicast_mode=0
set network.{{ name }}_bat.distributed_arp_table=0
set network.{{ name }}_bat.orig_interval=5000

set network.{{ name }}_mesh=interface
set network.{{ name }}_mesh.proto=batadv_hardif
set network.{{ name }}_mesh.master={{ name }}_bat
set network.{{ name }}_mesh.mtu=1532

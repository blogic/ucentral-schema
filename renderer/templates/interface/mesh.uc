
set network.batman=interface
set network.batman.proto=batadv
set network.batman.multicast_mode=0
set network.batman.distributed_arp_table=0
set network.batman.orig_interval=5000

{% if (ethernet.has_vlan(interface)): %}
set network.batman_v{{ this_vid }}=interface
set network.batman_v{{ this_vid }}.proto=batadv_vlan
set network.batman_v{{ this_vid }}.ifname='batman.{{ this_vid }}'
{% else %}
set network.batman_mesh=interface
set network.batman_mesh.proto=batadv_hardif
set network.batman_mesh.master=batman
set network.batman_mesh.mtu=1532
{% endif %}

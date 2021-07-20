{%
if (!interface.tunnel.server || !interface.tunnel.user_name || !interface.tunnel.password ) {
        warn("A L2TP tunnel can only be created with a server, username and password");
        return;
}
%}

# L2TP Configuration
set network.l2tp="interface"
set network.l2tp.proto="l2tp"
set network.l2tp.server={{ s(interface.tunnel.server) }}
set network.l2tp.username={{ s(interface.tunnel.user_name) }}
set network.l2tp.password={{ s(interface.tunnel.password) }}
set network.l2tp.ip4table="{{ routing_table.get(this_vid) }}"

add firewall zone
set firewall.@zone[-1].name="l2tp"
set firewall.@zone[-1].network="l2tp"
set firewall.@zone[-1].input="REJECT"
set firewall.@zone[-1].forward="REJECT"
set firewall.@zone[-1].output="REJECT"
set firewall.@zone[-1].masq="1"
set firewall.@zone[-1].mtu_fix="1"

add firewall forwarding
set firewall.@forwarding[-1].src="{{ name }}"
set firewall.@forwarding[-1].dest="l2tp"

add network rule
set network.@rule[-1].in="{{ name }}"
set network.@rule[-1].lookup="{{ routing_table.get(this_vid) }}"

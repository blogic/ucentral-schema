{%
if (!interface.vlan || !interface.vlan.id ) {
        warn("A GRE tunnel can only be created with a valid VLAN ID");
        return;
}
if (!interface.tunnel.peer_address) {
        warn("A GRE tunnel requires a valid peer-address");
        return;
}
%}

# GRE Configuration
set network.gre=interface
set network.gre.proto='gretap'
set network.gre.type='gre'
set network.gre.peeraddr='{{ interface.tunnel.peer_address }}'

{%
interface.type = 'bridge';
include("ip-auto.uc", {
	name: 'gretun_' + interface.vlan.id,
	netdev: 'gre4t-gre.' + interface.vlan.id,
	interface, location, ipv4_mode, ipv6_mode
});
%}

set network.gre_{{ interface.vlan.id }}=interface
set network.gre_{{ interface.vlan.id }}.ifname='gre.{{ interface.vlan.id }}'
set network.gre_{{ interface.vlan.id }}.network='gretun_{{ interface.vlan.id }}'
set network.gre_{{ interface.vlan.id }}.mtu='1500'

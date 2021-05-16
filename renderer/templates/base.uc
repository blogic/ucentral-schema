# Basic configuration
set network.loopback=interface
set network.loopback.ifname='lo'
set network.loopback.proto='static'
set network.loopback.ipaddr='127.0.0.1'
set network.loopback.netmask='255.0.0.0'

add network device
set network.@device[-1].name=up
set network.@device[-1].type=bridge

add network device
set network.@device[-1].name=down
set network.@device[-1].type=bridge

set firewall.wan=zone
set firewall.wan.name=wan
add_list firewall.wan.network=wan
set firewall.wan.input='REJECT'
set firewall.wan.output='ACCEPT'
set firewall.wan.forward='REJECT'
set firewall.wan.masq=1
set firewall.wan.mtu_fix=1

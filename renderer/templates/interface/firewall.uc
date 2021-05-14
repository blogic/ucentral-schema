{% for (let name in ethernet.calculate_names(interface)): %}
{% if (interface.role == "upstream"): %}
add firewall zone
set firewall.@zone[-1].name={{ s(name) }}
set firewall.@zone[-1].network={{ s(name) }}
set firewall.@zone[-1].input='REJECT'
set firewall.@zone[-1].output='ACCEPT'
set firewall.@zone[-1].forward='REJECT'
set firewall.@zone[-1].masq=1
set firewall.@zone[-1].mtu_fix=1
{% else %}
add firewall zone
set firewall.@zone[-1].name={{ s(name) }}
set firewall.@zone[-1].network={{ s(name) }}
set firewall.@zone[-1].input='ACCEPT'
set firewall.@zone[-1].output='ACCEPT'
set firewall.@zone[-1].forward='ACCEPT'

add firewall forwarding
set firewall.@forwarding[-1].src={{ name }}
set firewall.@forwarding[-1].dest='wan{{ interface.vlan ? interface.vlan.id : '' }}'
{% endif %}
{% endfor %}

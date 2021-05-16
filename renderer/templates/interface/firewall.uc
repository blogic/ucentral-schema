{% for (let name in ethernet.calculate_names(interface)): %}
{% if (interface.role == "upstream"): %}
add_list firewall.wan.network={{ s(name) }}
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

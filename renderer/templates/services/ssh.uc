
# SSH service configuration

set dropbear.@dropbear[-1].enable={{ b(length(filter(state.interfaces, interface => ("ssh" in interface.services)))) }}
set dropbear.@dropbear[-1].Port={{ s(ssh.port) }}
set dropbear.@dropbear[-1].PasswordAuth={{ b(ssh.password_authentication) }}
{% for (let key in ssh.authorized_keys): %}
add_list dropbear.@dropbear[-1].pubkey={{ s(key) }}
{% endfor %}

{% let interfaces = services.lookup_interfaces("ssh") %}
{% for (let interface in interfaces): %}
{%    let name = ethernet.calculate_name(interface) %}

add firewall rule
set firewall.@rule[-1].name='Allow-ssh-{{ name }}'
set firewall.@rule[-1].src='{{ name }}'
set firewall.@rule[-1].port='{{ ssh.port }}'
set firewall.@rule[-1].proto='tcp'
set firewall.@rule[-1].target='ACCEPT'
{% endfor %}

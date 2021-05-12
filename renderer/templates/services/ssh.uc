
# SSH service configuration

set dropbear.@dropbear[-1].enable={{ b(length(filter(state.interfaces, interface => ("ssh" in interface.services)))) }}
set dropbear.@dropbear[-1].port={{ s(ssh.port) }}
set dropbear.@dropbear[-1].PasswordAuth={{ b(ssh.password_authentication) }}
delete dropbear.@dropbear[-1].pubkey
{% for (let key in ssh.authorized_keys): %}
list_add dropbear.@dropbear[-1].pubkey={{ s(key) }}
{% endfor %}

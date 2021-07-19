{%
if (!interface.tunnel.server || !interface.tunnel.user_name || !interface.tunnel.password ) {
        warn("A L2TP tunnel can only be created with a server, username and password");
        return;
}
%}

# L2TP Configuration
set network.{{ name }}="interface"
set network.{{ name }}.proto="l2tp"
set network.{{ name }}.server={{ s(interface.tunnel.server) }}
set network.{{ name }}.username={{ s(interface.tunnel.user_name) }}
set network.{{ name }}.password={{ s(interface.tunnel.password) }}

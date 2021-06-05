{% if (!length(log)) return %}

# Syslog service configuration

set system.@system[-1].log_ip={{ s(log.host) }}
set system.@system[-1].log_port={{ s(log.port) }}
set system.@system[-1].log_proto={{ s(log.proto) }}
set system.@system[-1].log_size={{ s(log.size) }}

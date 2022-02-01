{%
if (!length(log)) return;
let hostname = state.unit?.hostname;
if (!hostname) {
	cursor.load("system");
	let system = cursor.get_all("system", "@system[-1]");
	hostname = system?.hostname || OpenWifi;
}
%}

# Syslog service configuration

set system.@system[-1].log_ip={{ s(log.host) }}
set system.@system[-1].log_port={{ s(log.port) }}
set system.@system[-1].log_proto={{ s(log.proto) }}
set system.@system[-1].log_size={{ s(log.size) }}
set system.@system[-1].log_priority={{ s(log.priority) }}
set system.@system[-1].log_hostname={{ s(hostname) }}


# NTP service configuration

delete system.ntp.server
set system.ntp.enabled={{ b(ntp.local_server) }}
set system.ntp.enable_server={{ b(ntp.servers) }}
{% for (let server in ntp.servers): %}
list_add system.ntp.server={{ s(server) }}
{% endfor %}

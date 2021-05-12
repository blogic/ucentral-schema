
# Wifi-Steering service configuration

# TODO work out how to set the network

{% if (wifi_steering.mode == 'local'): %}
set usteer.@usteer[-1].network={{ s(wifi_steering.network) }}
set usteer.@usteer[-1].key={{ s(wifi_steering.key) }}
{% else %}
delete usteer.@usteer[-1].network
delete usteer.@usteer[-1].key
{% endif %}


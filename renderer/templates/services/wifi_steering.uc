{% let ssids = services.lookup_ssids("wifi-steering") %}
{% let enable = (wifi_steering.mode == 'local' && length(ssids)) %}
{% services.set_enabled("usteer", enable) %}
{% if (!enable) return %}

# Wifi-Steering service configuration

add usteer usteer
set usteer.@usteer[-1].network='up'
set usteer.@usteer[-1].key={{ s(wifi_steering.key) }}
set usteer.@usteer[-1].assoc_steering={{ b(wifi_steering.assoc_steering) }}
set usteer.@usteer[-1].min_snr={{ wifi_steering.required_snr }}
set usteer.@usteer[-1].min_connect_snr={{ wifi_steering.required_probe_snr }}
set usteer.@usteer[-1].roam_scan_snr={{ wifi_steering.required_roam_snr }}
set usteer.@usteer[-1].load_kick_enabled={{ b(wifi_steering.load_kick_threshold) }}
set usteer.@usteer[-1].load_kick_threshold={{ wifi_steering.load_kick_threshold }}
{% for (let ssid in ssids): %}
add_list usteer.@usteer[-1].ssid_list={{ ssid.name }}
{% endfor %}

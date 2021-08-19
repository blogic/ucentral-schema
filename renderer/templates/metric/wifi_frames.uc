{% if (!wifi_frames) return %}

# Wifi-frame reporting configuration
set event.wifi=event
set event.wifi.type=wifi
set event.wifi.filter='*'
{% for (let n, filter in wifi_frames.filters): %}
{{ n ? 'add_list' : 'set' }} event.wifi.filter={{ filter }}
{% endfor %}

{% let interfaces = services.lookup_interfaces("mdns") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("umdns", enable) %}
{% if (!enable) return %}


# MDNS service configuration

add umdns umdns
set umdns.@umdns[-1].enable=1
{% for (let interface in interfaces): %}
add_list umdns.@umdns[-1].network={{ s(interface) }}
{% endfor %}

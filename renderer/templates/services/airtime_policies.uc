{% warn("airtime") %}
{% if (!services.is_present("airtime-policy")) return %}
{% let enable = b(length(airtime_policies.dns_match)) %}
{% services.set_enabled("airtime-policy", enable) %}
{% if (!enable) return %}
{% let name = ethernet.find_interface("upstream", 0) %}
# Airtime configuration

set airtime.airtime=config
set airtime.airtime.dns_weight={{ airtime_policies.dns_weight }}
{% for (let dns in airtime_policies.dns_match): %}
add_list airtime.airtime.dns_match={{ s(dns) }}
{% endfor %}

add firewall ipset
set firewall.@ipset[-1].name='match-airtime'
set firewall.@ipset[-1].match='ip'
set firewall.@ipset[-1].storage='hash'
set firewall.@ipset[-1].enabled='1'

add firewall include
set firewall.@include[-1].path='/etc/firewall.airtime'

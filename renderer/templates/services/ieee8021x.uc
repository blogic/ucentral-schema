{% let interfaces = services.lookup_interfaces("ieee8021x") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("ieee8021x", enable) %}
{% if (!enable) return %}

# IEEE8021x service configuration

{% for (let interface in interfaces): %}
{%   let name = ethernet.calculate_name(interface) %}
add ieee8021x network
set ieee8021x.@network[-1].network={{ name }}
{%  for (let port in ethernet.lookup_by_interface_spec(interface)): %}
add_list ieee8021x.@network[-1].ports={{ s(port) }}
{%  endfor %}
{%  for (let port in ethernet.lookup_by_interface_spec(interface)): %}

set network.{{ port }}=device
set network.@device[-1].name={{ s(port) }}
set network.@device[-1].auth='1'
{%  endfor %}
{% endfor %}

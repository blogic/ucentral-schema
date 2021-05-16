
# IGMP service configuration

{% if (igmp.enable): %}
{%  let interfaces = services.lookup_interfaces("igmp") %}
{%  for (let interface in interfaces): %}
{%    if (!interface.ipv4) continue; %}
{%    let name = ethernet.calculate_name(interface) %}
add igmpproxy phyint
set igmpproxy.@phyint[-1].network={{ name }}
set igmpproxy.@phyint[-1].zone={{ s((interface.role == "usptream") ? "wan" : name) }}
set igmpproxy.@phyint[-1].direction={{ s(interface.role) }}
{%   if (interface.role == "upstream"):  %}
set igmpproxy.@phyint[-1].altnet='0.0.0.0/0'
{%   endif %}
{%  endfor %}
{% endif %}

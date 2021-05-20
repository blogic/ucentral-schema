{% let afnames = ethernet.calculate_names(interface) %}
{% for (let afidx, afname in afnames): %}
set network.{{ afname }}=interface
set network.{{ afname }}.ucentral_name={{ s(interface.name) }}
set network.{{ afname }}.ucentral_path={{ s(location) }}
set network.{{ afname }}.ifname={{ netdev }}
set network.{{ afname }}.metric={{ interface.metric }}
set network.{{ afname }}.type={{ interface.type }}
{%  if (ipv4_mode == 'static' || ipv6_mode == 'static'): %}
set network.{{ afname }}.proto=static
{%  elif ((length(afnames) == 1 || afidx == 0) && ipv4_mode == 'dynamic'): %}
set network.{{ afname }}.proto=dhcp
{%  elif ((length(afnames) == 1 || afidx == 1) && ipv6_mode == 'dynamic'): %}
set network.{{ afname }}.proto=dhcpv6
{%  else %}
set network.{{ afname }}.proto=none
{%  endif %}
{%  if (interface.role == "downstream" && interface.vlan): %}
add network rule
set network.@rule[-1].in={{ afname }}
set network.@rule[-1].lookup={{ interface.vlan.id }}
{%  endif %}
{%  if ((length(afnames) == 1 && ipv4_mode != 'none') || (afidx == 0 && ipv4_mode != 'none')): %}
{%   include('ipv4.uc', { name: afname }) %}
{%  endif %}
{%  if ((length(afnames) == 1 && ipv6_mode != 'none') || (afidx == 1 && ipv6_mode != 'none')): %}
{%   include('ipv6.uc', { name: afname }) %}
{%  endif %}
{% endfor %}

add firewall rule
set firewall.@rule[-1].name='Allow traffic to {{ allow.destination_address }}'
set firewall.@rule[-1].family={{ s(family) }}
set firewall.@rule[-1].src={{ s(source_zone || '*') }}
set firewall.@rule[-1].dest={{ s(destination_zone) }}
{%  for (let proto in ((allow.protocol in ['any', 'all', '*'] && (allow.source_ports || allow.destination_ports)) ? ['tcp', 'udp'] : [ allow.protocol ])): %}
add_list firewall.@rule[-1].proto={{ s(proto) }}
{%  endfor %}
{%  if (allow.source_address): %}
set firewall.@rule[-1].src_ip={{ s(allow.source_address) }}
{%  endif %}
{%  for (let sport in allow.source_ports): %}
add_list firewall.@rule[-1].src_port={{ s(sport) }}
{%  endfor %}
set firewall.@rule[-1].dest_ip={{ ipcalc.expand_wildcard_address(allow.destination_address, destination_subnet) }}
{%  for (let dport in allow.destination_ports): %}
add_list firewall.@rule[-1].dest_port={{ s(dport) }}
{%  endfor %}
set firewall.@rule[-1].target=ACCEPT


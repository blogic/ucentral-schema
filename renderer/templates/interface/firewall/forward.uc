{% if (true || source_zone): %}
add firewall redirect
set firewall.@redirect[-1].name='Forward port {{ forward.external_port }} to {{ forward.internal_address }}'
set firewall.@redirect[-1].family={{ s(family) }}
set firewall.@redirect[-1].src={{ s(source_zone || '*') }}
set firewall.@redirect[-1].dest={{ s(destination_zone) }}
{%  for (let proto in ((forward.protocol in ['any', 'all', '*']) ? ['tcp', 'udp'] : [ forward.protocol ])): %}
add_list firewall.@redirect[-1].proto={{ s(proto) }}
{%  endfor %}
set firewall.@redirect[-1].src_dport={{ s(forward.external_port) }}
set firewall.@redirect[-1].dest_ip={{ ipcalc.expand_wildcard_address(forward.internal_address, destination_subnet) }}
set firewall.@redirect[-1].dest_port={{ s(forward.internal_port) }}
set firewall.@redirect[-1].target=DNAT

{% endif %}

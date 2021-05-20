{% if (interface.role == 'upstream' && interface.vlan): %}
set network.{{ name }}.ip6table={{ this_vid }}
{% endif %}
{% if (ipv6_mode == 'static'): %}
set network.{{ name }}.ip6addr={{ ipcalc.generate_prefix(state, ipv6.subnet, true) }}
set network.{{ name }}.ip6gw={{ ipv6.gateway }}
set network.{{ name }}.ip6assign={{ ipv6.prefix_size }}
{% else %}
set network.{{ name }}.reqprefix={{ ipv6.prefix_size || 'auto' }}
{% endif %}

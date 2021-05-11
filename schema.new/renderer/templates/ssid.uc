{%
	let phys = filter(map(ssid.wifi_bands, band => wiphy.lookup_by_band(band)), phy => phy && phy.section);

	if (!length(phys)) {
		warn("Can't find any suitable radio phy for SSID '%s' settings", ssid.name);

		return;
	}
%}

package wireless

{% for (let phy in phys): %}
{%  let id = wiphy.allocate_ssid_section_id(phy) %}
set wireless.{{ id }}=wifi-iface
set wireless.{{ id }}.device={{ phy.section }}
{%  for (let i, network in networks): %}
{{ i ? 'add_list' : 'set' }} wireless.{{ id }}.network={{ network }}
{%  endfor %}
set wireless.{{ id }}.ssid={{ s(ssid.name) }}
set wireless.{{ id }}.mode={{ ssid.bss_mode }}
set wireless.{{ id }}.bssid={{ ssid.bssid }}
set wireless.{{ id }}.hidden={{ b(ssid.hidden_ssid) }}
{% endfor %}

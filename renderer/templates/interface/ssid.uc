{%
	let phys = filter(map(ssid.wifi_bands, band => wiphy.lookup_by_band(band)), phy => phy && phy.section);

	if (!length(phys)) {
		warn("Can't find any suitable radio phy for SSID '%s' settings", ssid.name);

		return;
	}

	function validate_encryption() {
		if (!ssid.encryption || ssid.encryption.proto in [ "none" ])
			return {
				proto: 'none'
			};
		if (ssid.encryption.proto in [ "psk", "psk2", "psk-mixed", "sae", "sae-mixed" ] &&
		    ssid.encryption.key)
			return {
				proto: ssid.encryption.proto,
				key: ssid.encryption.key
		};
		if (ssid.encryption.proto in [ "wpa", "wpa2", "wpa-mixed", "wpa3", "wpa3-mixed" ] &&
		    ssid.encryption.radius && ssid.encryption.radius.authentication &&
		    ssid.encryption.radius.authentication.host &&
		    ssid.encryption.radius.authentication.port &&
		    ssid.encryption.radius.authentication.secret)
			return {
				proto: ssid.encryption.proto,
				auth: ssid.encryption.ssid.encryption.radius.authentication,
				acct: ssid.encryption.ssid.encryption.radius.accounting
			};
		return false;
	}

	function match_ieee80211w() {
		if (ssid.encryption.proto in [ "sae", "sae-mixed", "wpa3", "wpa3-mixed" ])
			return 2;

		return index([ "disabled", "optional", "required" ], ssid.encryption.ieee80211w);
	}
%}

# Wireless configuration
{% for (let phy in phys): %}
{%  let id = wiphy.allocate_ssid_section_id(phy) %}
{%  let crypto = validate_encryption(); %}
{%  if (!crypto) continue; %}
add wireless wifi-iface
set wireless.@wifi-iface[-1].ucentral_path={{ s(location) }}
set wireless.@wifi-iface[-1].device={{ phy.section }}
{% if (ssid.bss_mode == 'mesh'): %}
set wireless.@wifi-iface[-1].mode={{ ssid.bss_mode }}
set wireless.@wifi-iface[-1].mesh_id={{ s(ssid.name) }}
set wireless.@wifi-iface[-1].mesh_fwding=0
set wireless.@wifi-iface[-1].network={{ name }}_mesh
{% endif %}
{% if (ssid.bss_mode == 'ap'): %}
{%  for (let i, name in ethernet.calculate_names(interface)): %}
{{ i ? 'add_list' : 'set' }} wireless.@wifi-iface[-1].network={{ name }}
{%  endfor %}
set wireless.@wifi-iface[-1].ssid={{ s(ssid.name) }}
set wireless.@wifi-iface[-1].mode={{ ssid.bss_mode }}
set wireless.@wifi-iface[-1].bssid={{ ssid.bssid }}
set wireless.@wifi-iface[-1].hidden={{ b(ssid.hidden_ssid) }}
set wireless.@wifi-iface[-1].time_advertisement={{ ssid.broadcast_time }}
set wireless.@wifi-iface[-1].isolate={{ b(ssid.isolate_clients) }}
set wireless.@wifi-iface[-1].uapsd={{ b(ssid.power_save) }}
set wireless.@wifi-iface[-1].rts_threshold={{ ssid.rts_threshold }}
set wireless.@wifi-iface[-1].multicast_to_unicast={{ b(ssid.unicast_conversion) }}
{%  if (ssid.rrm): %}
set wireless.@wifi-iface[-1].ieee80211k={{ b(ssid.rrm.neighbor_reporting) }}
set wireless.@wifi-iface[-1].ftm_responder={{ b(ssid.rrm.ftm_responder) }}
set wireless.@wifi-iface[-1].stationary_ap={{ b(ssid.rrm.stationary_ap) }}
set wireless.@wifi-iface[-1].lci={{ b(ssid.rrm.lci) }}
set wireless.@wifi-iface[-1].civic={{ ssid.rrm.civic }}
{%  endif %}
{%  if (ssid.roaming): %}
set wireless.@wifi-iface[-1].ieee80211r=1
set wireless.@wifi-iface[-1].ft_over_ds={{ b(ssid.roaming.message_exchange == "ds") }}
set wireless.@wifi-iface[-1].ft_psk_generate_local={{ b(ssid.roaming.generate_psk) }}
set wireless.@wifi-iface[-1].mobility_domain={{ ssid.roaming.domain_identifier }}
{%  endif %}
{% endif %}
{% if (ssid.rates): %}
set wireless.@wifi-iface[-1].beacon_rate={{ ssid.rates.beacon }}
set wireless.@wifi-iface[-1].mcast_rate={{ ssid.rates.multicast }}
{% endif %}
set wireless.@wifi-iface[-1].ieee80211w={{ match_ieee80211w() }}
set wireless.@wifi-iface[-1].encryption={{ crypto.proto }}
set wireless.@wifi-iface[-1].key={{ crypto.key }}
{% if (crypto.auth): %}
set wireless.@wifi-iface[-1].auth_server={{ crypto.auth.host }}
set wireless.@wifi-iface[-1].auth_port={{ crypto.auth.port }}
set wireless.@wifi-iface[-1].auth_secret={{ crypto.auth.secret }}
{% endif %}
{% if (crypto.acct): %}
set wireless.@wifi-iface[-1].acct_server={{ crypto.acct.host }}
set wireless.@wifi-iface[-1].acct_port={{ crypto.acct.port }}
set wireless.@wifi-iface[-1].acct_secret={{ crypto.acct.secret }}
set wireless.@wifi-iface[-1].acct_interval={{ crypto.acct.interval }}
{% endif %}

{% if (ssid.rate_limit && (ssid.rate_limit.ingress_rate || ssid.rate_limit.egress_rate)): %}
add ratelimit rate
set ratelimit.@rate[-1].ssid={{ s(ssid.name) }}
set ratelimit.@rate[-1].ingress={{ ssid.rate_limit.ingress_rate }}
set ratelimit.@rate[-1].egress={{ ssid.rate_limit.egress_rate }}

{% endif %}
{% endfor %}

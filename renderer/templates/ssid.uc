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
set wireless.{{ id }}=wifi-iface
set wireless.{{ id }}.device={{ phy.section }}
{%  for (let i, network in networks): %}
{{ i ? 'add_list' : 'set' }} wireless.{{ id }}.network={{ network }}
{%  endfor %}
set wireless.{{ id }}.ssid={{ s(ssid.name) }}
set wireless.{{ id }}.mode={{ ssid.bss_mode }}
set wireless.{{ id }}.bssid={{ ssid.bssid }}
set wireless.{{ id }}.hidden={{ b(ssid.hidden_ssid) }}
set wireless.{{ id }}.time_advertisement={{ ssid.broadcast_time }}
set wireless.{{ id }}.isolate={{ b(ssid.isolate_clients) }}
set wireless.{{ id }}.uapsd={{ b(ssid.power_save) }}
set wireless.{{ id }}.rts_threshold={{ ssid.rts_threshold }}
set wireless.{{ id }}.multicast_to_unicast={{ b(ssid.unicast_conversion) }}
set wireless.{{ id }}.beacon_rate={{ ssid.rates.beacon }}
set wireless.{{ id }}.mcast_rate={{ ssid.rates.multicast }}
{% if (ssid.rrm): %}
set wireless.{{ id }}.ieee80211k={{ b(ssid.rrm.neighbor_reporting) }}
set wireless.{{ id }}.ftm_responder={{ b(ssid.rrm.ftm_responder) }}
set wireless.{{ id }}.stationary_ap={{ b(ssid.rrm.stationary_ap) }}
set wireless.{{ id }}.lci={{ b(ssid.rrm.lci) }}
set wireless.{{ id }}.civic={{ ssid.rrm.civic }}
{% endif %}
{% if (ssid.roaming): %}
set wireless.{{ id }}.ieee80211r=1
set wireless.{{ id }}.ft_over_ds={{ b(ssid.roaming.message_exchange == "ds") }}
set wireless.{{ id }}.ft_psk_generate_local={{ b(ssid.roaming.generate_psk) }}
set wireless.{{ id }}.mobility_domain={{ ssid.roaming.domain_identifier }}
{% endif %}
set wireless.{{ id }}.ieee80211w={{ match_ieee80211w() }}
set wireless.{{ id }}.encryption={{ crypto.proto }}
set wireless.{{ id }}.key={{ crypto.key }}
{% if (crypto.auth): %}
set wireless.{{ id }}.auth_server={{ crypto.auth.host }}
set wireless.{{ id }}.auth_port={{ crypto.auth.port }}
set wireless.{{ id }}.auth_secret={{ crypto.auth.secret }}
{% endif %}
{% if (crypto.acct): %}
set wireless.{{ id }}.acct_server={{ crypto.acct.host }}
set wireless.{{ id }}.acct_port={{ crypto.acct.port }}
set wireless.{{ id }}.acct_secret={{ crypto.acct.secret }}
set wireless.{{ id }}.acct_interval={{ crypto.acct.interval }}
{% endif %}

{% if (ssid.rate_limit.ingress_rate || ssid.rate_limit.egress_rate): %}
add ratelimit rate
set ratelimit.@rate[-1].ssid={{ s(ssid.name) }}
set ratelimit.@rate[-1].ingress={{ ssid.rate_limit.ingress_rate }}
set ratelimit.@rate[-1].egress={{ ssid.rate_limit.egress_rate }}

{% endif %}
{% endfor %}

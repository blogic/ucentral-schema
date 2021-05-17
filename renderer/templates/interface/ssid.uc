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
{% for (let n, phy in phys): %}
{%   let section = name + '_' + n + '_' + count; %}
{%   let id = wiphy.allocate_ssid_section_id(phy) %}
{%   let crypto = validate_encryption(); %}
{%   if (!crypto) continue; %}
set wireless.{{ section }}=wifi-iface
set wireless.{{ section }}.ucentral_path={{ s(location) }}
set wireless.{{ section }}.device={{ phy.section }}
{%   if (ssid.bss_mode == 'mesh'): %}
set wireless.{{ section }}.mode={{ ssid.bss_mode }}
set wireless.{{ section }}.mesh_id={{ s(ssid.name) }}
set wireless.{{ section }}.mesh_fwding=0
set wireless.{{ section }}.network={{ name }}_mesh
{%   endif %}
{%   if (ssid.bss_mode == 'ap'): %}
{%     for (let i, name in ethernet.calculate_names(interface)): %}
{{ i ? 'add_list' : 'set' }} wireless.{{ section }}.network={{ name }}
{%     endfor %}
set wireless.{{ section }}.ssid={{ s(ssid.name) }}
set wireless.{{ section }}.mode={{ ssid.bss_mode }}
set wireless.{{ section }}.bssid={{ ssid.bssid }}
set wireless.{{ section }}.hidden={{ b(ssid.hidden_ssid) }}
set wireless.{{ section }}.time_advertisement={{ ssid.broadcast_time }}
set wireless.{{ section }}.isolate={{ b(ssid.isolate_clients) }}
set wireless.{{ section }}.uapsd={{ b(ssid.power_save) }}
set wireless.{{ section }}.rts_threshold={{ ssid.rts_threshold }}
set wireless.{{ section }}.multicast_to_unicast={{ b(ssid.unicast_conversion) }}
{%     if (ssid.rrm): %}
set wireless.{{ section }}.ieee80211k={{ b(ssid.rrm.neighbor_reporting) }}
set wireless.{{ section }}.ftm_responder={{ b(ssid.rrm.ftm_responder) }}
set wireless.{{ section }}.stationary_ap={{ b(ssid.rrm.stationary_ap) }}
set wireless.{{ section }}.lci={{ b(ssid.rrm.lci) }}
set wireless.{{ section }}.civic={{ ssid.rrm.civic }}
{%     endif %}
{%     if (ssid.roaming): %}
set wireless.{{ section }}.ieee80211r=1
set wireless.{{ section }}.ft_over_ds={{ b(ssid.roaming.message_exchange == "ds") }}
set wireless.{{ section }}.ft_psk_generate_local={{ b(ssid.roaming.generate_psk) }}
set wireless.{{ section }}.mobility_domain={{ ssid.roaming.domain_identifier }}
{%     endif %}
{%   endif %}
{%   if (ssid.rates): %}
set wireless.{{ section }}.beacon_rate={{ ssid.rates.beacon }}
set wireless.{{ section }}.mcast_rate={{ ssid.rates.multicast }}
{%   endif %}
set wireless.{{ section }}.ieee80211w={{ match_ieee80211w() }}
set wireless.{{ section }}.encryption={{ crypto.proto }}
set wireless.{{ section }}.key={{ crypto.key }}
{%   if (crypto.auth): %}
set wireless.{{ section }}.auth_server={{ crypto.auth.host }}
set wireless.{{ section }}.auth_port={{ crypto.auth.port }}
set wireless.{{ section }}.auth_secret={{ crypto.auth.secret }}
{%   endif %}
{%   if (crypto.acct): %}
set wireless.{{ section }}.acct_server={{ crypto.acct.host }}
set wireless.{{ section }}.acct_port={{ crypto.acct.port }}
set wireless.{{ section }}.acct_secret={{ crypto.acct.secret }}
set wireless.{{ section }}.acct_interval={{ crypto.acct.interval }}
{%   endif %}
{%   if (ssid.rate_limit && (ssid.rate_limit.ingress_rate || ssid.rate_limit.egress_rate)): %}

add ratelimit rate
set ratelimit.@rate[-1].ssid={{ s(ssid.name) }}
set ratelimit.@rate[-1].ingress={{ ssid.rate_limit.ingress_rate }}
set ratelimit.@rate[-1].egress={{ ssid.rate_limit.egress_rate }}
{%   endif %}
{%   for (let psk in ssid.multi_psk): %}
{%     if (!psk.key) continue %}

add wireless wifi-station
set wireless.@wifi-station[-1].iface={{ s(section) }}
set wireless.@wifi-station[-1].mac={{ psk.mac }}
set wireless.@wifi-station[-1].key={{ psk.key }}
set wireless.@wifi-station[-1].vid={{ psk.vlan_id }}
{%   endfor %}
{% endfor %}

{%
	let phys = [];

	for (let band in ssid.wifi_bands)
		for (let phy in wiphy.lookup_by_band(band))
			if (phy.section)
				push(phys, phy);

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
		    ssid.radius && ssid.radius.local)
			if (ssid.radius.local.use_local_certificates) {
				cursor.load("system");
				let certs = cursor.get_all("system", "@certificates[-1]");
				ssid.radius.local.ca_certificate = certs.ca;
				ssid.radius.local.server_certificate = certs.cert;
				ssid.radius.local.private_key = certs.key;
			}

			return {
				proto: ssid.encryption.proto,
				eap_local: ssid.radius.local,
				eap_user: "/tmp/ucentral/" + replace(location, "/", "_") + ".eap_user"
			};


		if (ssid.encryption.proto in [ "wpa", "wpa2", "wpa-mixed", "wpa3", "wpa3-mixed" ] &&
		    ssid.radius && ssid.radius.authentication &&
		    ssid.radius.authentication.host &&
		    ssid.radius.authentication.port &&
		    ssid.radius.authentication.secret)
			return {
				proto: ssid.encryption.proto,
				auth: ssid.radius.authentication,
				acct: ssid.radius.accounting,
				radius: ssid.radius
			};
		warn("Can't find any valid encryption settings");
		return false;
	}

	function match_ieee80211w() {
		if (ssid.encryption.proto in [ "sae", "sae-mixed", "wpa3", "wpa3-mixed" ])
			return 2;

		return index([ "disabled", "optional", "required" ], ssid.encryption.ieee80211w);
	}

	function match_wds() {
		return index([ "wds-ap", "wds-sta", "wds-repeater" ], ssid.bss_mode) >= 0;
	}

	function match_hs20_auth_type(auth_type) {
		let types = {
			"terms-and-conditions": "00",
			"online-enrollment": "01",
			"http-redirection": "02",
			"dns-redirection": "03"
		};
		return (auth_type && auth_type.type) ? types[auth_type.type] : '';
	}

	let bss_mode = ssid.bss_mode;
	if (ssid.bss_mode == "wds-ap")
		bss_mode =  "ap";
	if (ssid.bss_mode == "wds-sta")
		bss_mode =  "sta";
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
{%   if (bss_mode == 'mesh'): %}
set wireless.{{ section }}.mode={{ bss_mode }}
set wireless.{{ section }}.mesh_id={{ s(ssid.name) }}
set wireless.{{ section }}.mesh_fwding=0
set wireless.{{ section }}.network={{ name }}_mesh
{%   endif %}
{%   if (index([ 'ap', 'sta' ], bss_mode) >= 0): %}
{%     for (let i, name in ethernet.calculate_names(interface)): %}
{{ i ? 'add_list' : 'set' }} wireless.{{ section }}.network={{ name }}
{%     endfor %}
set wireless.{{ section }}.ssid={{ s(ssid.name) }}
set wireless.{{ section }}.mode={{ s(bss_mode) }}
set wireless.{{ section }}.bssid={{ ssid.bssid }}
set wireless.{{ section }}.proxy_arp={{ b(ssid.proxy_arp) }}
{%   endif %}
{%   if (bss_mode == 'ap'): %}
set wireless.{{ section }}.hidden={{ b(ssid.hidden_ssid) }}
set wireless.{{ section }}.time_advertisement={{ ssid.broadcast_time }}
set wireless.{{ section }}.isolate={{ b(ssid.isolate_clients) }}
set wireless.{{ section }}.uapsd={{ b(ssid.power_save) }}
set wireless.{{ section }}.rts_threshold={{ ssid.rts_threshold }}
set wireless.{{ section }}.multicast_to_unicast={{ b(ssid.unicast_conversion) }}
set wireless.{{ section }}.maxassoc={{ ssid.maximum_clients }}
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
set wireless.{{ section }}.r0kh={{ s(ssid.roaming.pmk_r0_key_holder) }}
set wireless.{{ section }}.r1kh={{ s(ssid.roaming.pmk_r1_key_holder) }}
{%     endif %}
{%   endif %}
{%   if (ssid.rates): %}
set wireless.{{ section }}.beacon_rate={{ ssid.rates.beacon }}
set wireless.{{ section }}.mcast_rate={{ ssid.rates.multicast }}
{%   endif %}
{%   if (ssid.quality_tresholds): %}
set wireless.{{ section }}.rssi_reject_assoc_rssi={{ ssid.quality_tresholds.association-request-rssi }}
set wireless.{{ section }}.rssi_ignore_probe_request={{ ssid.quality_tresholds.probe-request-rssi }}
{%   endif %}
set wireless.{{ section }}.ieee80211w={{ match_ieee80211w() }}
set wireless.{{ section }}.encryption={{ crypto.proto }}
set wireless.{{ section }}.key={{ crypto.key }}
{%   if (crypto.radius): %}
set wireless.{{ section }}.request_cui={{ b(crypto.radius.chargeable_user_id) }}
set wireless.{{ section }}.nasid={{ s(crypto.radius.nas_identifier) }}
set wireless.{{ section }}.dynamic_vlan=1
{%   endif %}
{%   if (crypto.eap_local): %}
set wireless.{{ section }}.eap_server=1
set wireless.{{ section }}.ca_cert={{ s(crypto.eap_local.ca_certificate) }}
set wireless.{{ section }}.server_cert={{ s(crypto.eap_local.server_certificate) }}
set wireless.{{ section }}.private_key={{ s(crypto.eap_local.private_key) }}
set wireless.{{ section }}.private_key_passwd={{ s(crypto.eap_local.private_key_password) }}
set wireless.{{ section }}.server_id={{ s(crypto.eap_local.server_identity) }}
set wireless.{{ section }}.eap_user_file={{ s(crypto.eap_user) }}
{%	let user_file = fs.open(crypto.eap_user, "w");
	for (let user in crypto.eap_local.users)
		user_file.write('"' + user.user_name + '"\tPWD\t"' + user.password + '"\n');
	if (crypto.eap_local.ca_certificate && crypto.eap_local.server_certificate && crypto.eap_local.private_key)
		user_file.write('* TLS,TTLS\n');
	user_file.close();
     endif %}
{%   if (crypto.auth): %}
set wireless.{{ section }}.auth_server={{ crypto.auth.host }}
set wireless.{{ section }}.auth_port={{ crypto.auth.port }}
set wireless.{{ section }}.auth_secret={{ crypto.auth.secret }}
{%     for (let request in crypto.auth.request_attribute): %}
add_list wireless.{{ section }}.radius_auth_req_attr={{ s(request.id + ':' + request.value) }}
{%     endfor %}
{%   endif %}
{%   if (crypto.acct): %}
set wireless.{{ section }}.acct_server={{ crypto.acct.host }}
set wireless.{{ section }}.acct_port={{ crypto.acct.port }}
set wireless.{{ section }}.acct_secret={{ crypto.acct.secret }}
set wireless.{{ section }}.acct_interval={{ crypto.acct.interval }}
{%     for (let request in crypto.acct.request_attribute): %}
add_list wireless.{{ section }}.radius_acct_req_attr={{ s(request.id + ':' + request.value) }}
{%     endfor %}
{%   endif %}
{%   if (ssid.pass_point): %}
set wireless.{{ section }}.interworking=1
set wireless.{{ section }}.hs20=1
{%     for (let name in ssid.pass_point.venue_name): %}
add_list wireless.{{ section }}.iw_venue_name={{ s(name) }}
{%     endfor %}
set wireless.{{ section }}.iw_venue_group='{{ ssid.pass_point.venue_group }}'
set wireless.{{ section }}.iw_venue_type='{{ ssid.pass_point.venue_type }}'
{%     for (let n, url in ssid.pass_point.venue_url): %}
add_list wireless.{{ section }}.iw_venue_url={{ s((n + 1) + ":" +url) }}
{%     endfor %}
set wireless.{{ section }}.iw_network_auth_type='{{ match_hs20_auth_type(ssid.pass_point.auth_type) }}'
set wireless.{{ section }}.iw_domain_name={{ s(ssid.pass_point.domain_name) }}
{%     for (let realm in ssid.pass_point.nai_realm): %}
set wireless.{{ section }}.iw_nai_realm='{{ realm }}'
{%     endfor %}
set wireless.{{ section }}.osen={{ b(ssid.pass_point.osen) }}
set wireless.{{ section }}.anqp_domain_id='{{ ssid.pass_point.anqp_domain }}'
{%     for (let name in ssid.pass_point.friendly_name): %}
add_list wireless.{{ section }}.hs20_oper_friendly_name={{ s(name) }}
{%     endfor %}
{%     for (let icon in ssid.pass_point.icon): %}
add_list wireless.{{ section }}.operator_icon={{ s(icon.uri) }}
{%     endfor %}
{%   endif %}

set wireless.{{ section }}.wds='{{ b(match_wds()) }}'
add wireless wifi-vlan
set wireless.@wifi-vlan[-1].iface={{ section }}
set wireless.@wifi-vlan[-1].name='v#'
set wireless.@wifi-vlan[-1].vid='*'
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

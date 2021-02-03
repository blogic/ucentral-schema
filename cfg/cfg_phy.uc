{%
function ssid_generate(x, v, radio, c)  {
	local crypto = "none";

	if (!uci_requires(v, [ "network", "mode", "encryption"])) {
		cfg_error("ssid is missing a required option");
		return;
	}

	switch(v.mode) {
	case "ap":
	case "sta":
		if (!uci_requires(v, [ "ssid" ])) {
			cfg_error("missing ssid field");
			return;
		}
		break;
	case "mesh":
		uci_defaults(v, { "mesh_fwding": 0, "mcast_rate": 24000	 });
		if (!uci_requires(v, [ "mesh_id" ])) {
			cfg_error("missing mesh fields");
			return;
		}
		break;
	}

	if (v.encryption in [ "psk", "psk2", "psk-mixed" ]) {
		if (!uci_requires(v, [ "key"])) {
			cfg_error("ssid has invalid psk options");
			return;
		}
		crypto = "psk";
	} else if (v.encryption in [ "wpa", "wpa2", "wpa-mixed", "sae", "sae-mixed" ]) {
		if (!uci_requires(v, [ "server", "port", "auth_secret" ])) {
			cfg_error("ssid has invalid wpa options");
			return;
		}
		crypto = "wpa";
	}

	if (x.he_mac_capa)
		uci_defaults(v, { "he_bss_color": 64, "multiple_bssid": 0, "ema": 0 });

	local name = sprintf("%s_%s", radio, v.network);
	local u = uci_new_section(x, name, "wifi-iface", { "device": radio });
	uci_set_options(u, v, ["ssid", "network", "mode", "dtim_period", "hidden",
			"ieee80211r", "ieee80211k", "ieee80211v", "ieee80211w",
			"isolate", "rts_threshold", "uapsd", "ft_over_ds",
			"ft_psk_generate_local", "mobility_domain", "encryption"]);

	switch(crypto) {
	case "psk":
		uci_set_option(u, v, "key");
		break;
	case "wpa":
		uci_set_options(u, v, [ "server", "port", "auth_secret" ]);
		break;
	}

	switch(v.mode) {
	case "ap":
	case "sta":
		uci_set_option(u, v, "ssid");
		break;
	case "mesh":
		uci_set_options(u, v, [ "mesh_fwding", "mesh_id", "mcast_rate" ]);
		break;
	}
}

function phy_htmode_verify(c, v) {
	if (index(v, "HE") == 0 && c.he_mac_capa)
		return v;
	if (index(v, "VHT") == 0 && c.vht_capa)
		return v;
	if (index(v, "HT") == 0 && c.ht_capa)
		return v;
	cfg_error("invalid htmode, dropping to ht20");
	return "HT20";
}

function phy_channel_verify(c, v) {
	if (v <= 16 && "2" in c.band)
		return v;
	if (v >= 32 && v <= 68 && ("5" in c.band || "5l" in c.band))
		return v;
	if (v >= 96 && v <= 173 && ("5" in c.band || "5u" in c.band))
		return v;
	return 0;
}

function phy_generate_options(x, c, v) {
	local u = uci_new_section(x, c.uci, "wifi-device");

	if (v.htmode)
		u.htmode = phy_htmode_verify(c, v.htmode);
	if (v.channel)
		u.channel = phy_channel_verify(c, v.channel);

	uci_set_options(u, v, ["disabled", "country", "beacon_int", "txpower",
		"chanbw", "require_mode", "txantenna", "rxantenna", "legacy_rates"]);
}

function phy_generate(wifi, x) {
	for (local phy in cfg.phy):
		if (phy.band in x.band === false)
			continue;

		phy_generate_options(wifi, x, phy.cfg);

		for (local ssid in cfg.ssid):
			for (local band in ssid.band):
				if (band != phy.band)
					continue;
				ssid_generate(wifi, ssid.cfg, x.uci, x);
			endfor
		endfor
		return true;
	endfor
	return false;
}

function wifi_generate() {
	local wifi= {};

	if (!capab.wifi)
		return;

	cursor = uci.cursor();
	cursor.load("wireless");
	cursor.foreach("wireless", "wifi-device", function(d) {
		if (capab.wifi[d.path])
			capab.wifi[d.path]["uci"] = d[".name"];
	});

	for (local path in capab.wifi):
		local phy = capab.wifi[path];

		if (phy_generate(wifi, phy) === false):
			wifi[phy.uci] = {"disabled": "1"};
		endif
	endfor
	uci_render("wireless", wifi);
}

wifi_generate();
%}

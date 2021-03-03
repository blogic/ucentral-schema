{%
function ssid_generate(x, v, radio, c)  {
	let crypto = "none";

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

	if (v.encryption in [ "psk", "psk2", "psk-mixed", "sae", "sae-mixed" ]) {
		if (!uci_requires(v, [ "key"])) {
			cfg_error("ssid has invalid psk options");
			return;
		}
		crypto = "psk";
	} else if (v.encryption in [ "wpa", "wpa2", "wpa-mixed", "wpa3", "wpa3-mixed" ]) {
		if (!uci_requires(v, [ "server", "port", "auth_secret" ])) {
			cfg_error("ssid has invalid wpa options");
			return;
		}
		crypto = "wpa";
	}

	if (v.encryption in [ "sae", "sae-mixed", "wpa3", "wpa3-mixed" ])
		v.ieee80211w = 2;

	if (x.he_mac_capa)
		uci_defaults(v, { "he_bss_color": 64, "multiple_bssid": 0, "ema": 0 });

	if (!v.name)
		v.name = v.network;

	let name = sprintf("%s_%s", radio, v.name);
	let u = uci_new_section(x, name, "wifi-iface", { "device": radio });
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
	if (v in c.htmode)
		return v;
	cfg_error("invalid htmode, dropping to HT20");
	return "HT20";
}

function phy_htmode_best(c, v) {
	let a;

	for (a in [ "HE", "VHT", "HT"]) {
		let htmode = sprintf("%s%s", a, v);

		if (htmode in c.htmode)
			return htmode;
	}
	cfg_error("invalid htwidth, dropping to HT20");
	return "HT20";
}

function phy_channel_verify(c, v) {
	if (v in c.channels)
		return v;
	cfg_error(sprintf("invalid channel, falling back to %d", c.channels[0]));
	return c.channels[0];
}

let mimo = { "1x1": 1, "2x2": 3, "3x3": 8, "4x4": 15, "8x8": 255};

function phy_get_mimo(request, max) {
	let v = mimo[request];

	if (!v || v > max) {
		cfg_error(sprintf("invalid mimo setting, using %d", max));
		return max;
	}
	return v;
}

function phy_generate_options(x, c, v) {
	let u = uci_new_section(x, c.uci, "wifi-device");

	if (v.htmode)
		u.htmode = phy_htmode_verify(c, v.htmode);
	else if (v.htwidth)
		u.htmode = phy_htmode_best(c, v.htwidth);
	if (v.channel)
		u.channel = phy_channel_verify(c, v.channel);
	if (v.mimo) {
		u.txantenna = phy_get_mimo(v.mimo, c.tx_ant);
		u.rxantenna = phy_get_mimo(v.mimo, c.rx_ant);
	}
	uci_set_options(u, v, ["disabled", "country", "beacon_int", "txpower",
		"chanbw", "require_mode", "legacy_rates"]);
}

function phy_generate(wifi, x) {
	for (let phy in cfg.phy):
		if (phy.band in x.band === false)
			continue;

		phy_generate_options(wifi, x, phy.cfg);

		for (let ssid in cfg.ssid):
			for (let band in ssid.band):
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
	let wifi= {};

	if (!capab.wifi)
		return;

	cursor = uci.cursor();
	cursor.load("wireless");
	cursor.foreach("wireless", "wifi-device", function(d) {
		if (capab.wifi[d.path])
			capab.wifi[d.path]["uci"] = d[".name"];
	});

	for (let path in capab.wifi):
		let phy = capab.wifi[path];
		if (!phy.uci)
			continue;
		if (phy_generate(wifi, phy) === false):
			wifi[phy.uci] = {"disabled": "1"};
		endif
	endfor
	uci_render("wireless", wifi);
}

wifi_generate();
%}

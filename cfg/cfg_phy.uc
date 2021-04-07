{%
	let station_count = 0;

	function station_generate(x, v, iface) {
		for (let sta in v) {
			if (!uci_requires(sta, [ "key" ]))
				continue;
			let u = uci_new_section(x, "station" + station_count++,
						"wifi-station", { iface: iface });
			uci_set_options(u, sta, [
				"mac", "vid", "key"
			]);
		}
	}

	let vlan_count = 0;

	function vlan_generate(x, v, iface) {
		for (let vlan in v) {
			if (!uci_requires(vlan, [ "network", "vid" ]))
				return;
			uci_new_section(x, "vlan" + vlan_count++, "wifi-vlan",
					{ iface: iface, name: vlan.network,
					  network: vlan.network, vid: vlan.vid });
		}
	}

	let rate_count = 0;

	function rate_generate(rate, v) {
		let vals = { ssid: v.ssid };
		if (v.rate_ingress)
			vals.ingress = v.rate_ingress;
		if (v.rate_egress)
			vals.egress = v.rate_egress;
		uci_new_section(rate, "rate" + rate_count++, "rate", vals);
	}

	function ssid_generate(x, v, radio, c, rate) {
		let crypto = "none";

		if (!uci_requires(v, [ "network", "mode", "encryption"])) {
			cfg_rejected("wifi.ssid", "", "ssid is missing a required option");
			return;
		}

		uci_defaults(v, { wpa_disable_eapol_key_retries: 1 });

		switch(v.mode) {
		case "ap":
		case "sta":
			if (!uci_requires(v, [ "ssid" ])) {
				cfg_rejected("wifi.ssid", "", "missing ssid field");
				return;
			}
			break;

		case "mesh":
			uci_defaults(v, { mesh_fwding: 0, mcast_rate: 24000 });
			if (!uci_requires(v, [ "mesh_id" ])) {
				cfg_rejected("wifi.mesh", "", "missing mesh fields");
				return;
			}
			break;
		}

		if (v.encryption in [ "psk", "psk2", "psk-mixed", "sae", "sae-mixed" ]) {
			if (!uci_requires(v, [ "key"])) {
				cfg_rejected("wifi.ssid." + v.ssid, "", "ssid has invalid psk options");
				return;
			}

			crypto = "psk";
		}
		else if (v.encryption in [ "wpa", "wpa2", "wpa-mixed", "wpa3", "wpa3-mixed" ]) {
			if (!uci_requires(v, [ "server", "port", "auth_secret" ])) {
				cfg_rejected("wifi.ssid." + v.ssid, "", "ssid has invalid wpa options");
				return;
			}

			crypto = "wpa";
		}

		if (v.encryption in [ "sae", "sae-mixed", "wpa3", "wpa3-mixed" ])
			v.ieee80211w = 2;

		if (v.time_zone)
			uci_defaults(v, { time_advertisement: 2 });

		if (!v.name)
			v.name = v.network;

		let name = sprintf("%s_%s", radio, v.name);
		let u = uci_new_section(x, name, "wifi-iface", { device: radio });

		uci_set_options(u, v, [
			"ssid", "network", "mode", "dtim_period", "hidden",
			"ieee80211r", "ieee80211k", "ieee80211v", "ieee80211w",
			"isolate", "rts_threshold", "uapsd", "ft_over_ds",
			"ft_psk_generate_local", "mobility_domain", "encryption",
			"ftm_responder", "stationary_ap", "civic", "lci",
			"time_advertisement", "time_zone"
		]);

		switch(crypto) {
		case "psk":
			uci_set_option(u, v, "key");
			break;

		case "wpa":
			uci_set_options(u, v, [ "server", "port", "auth_secret",
						"acct_server", "acct_port", "acct_secret",
						"acct_interval", "radius_auth_req_attr",
						"radius_acct_req_attr", "request_cui"
			]);
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

		if (v.interworking) {
			uci_set_options(u, v, [ "interworking", "iw_venue_name", "iw_venue_group", "iw_venue_type",
						"iw_venue_url", "iw_network_auth_type", "iw_domain_name", "iw_nai_realm"
			]);
		}

		if (v.hs20) {
			uci_set_options(u, v, [ "hs20", "osen", "anqp_domain_id", "hs20_oper_friendly_name", "operator_icon" ]);
		}

		if (v.mode == "ap" && length(v.multi_psk))
			station_generate(x, v.multi_psk, name);
		if (v.mode == "ap" && length(v.multi_vlan))
			vlan_generate(x, v.multi_vlan, name);
		if (v.rate_ingress || v.rate_egress)
			rate_generate(rate, v);
	}

	function phy_htmode_verify(c, v) {
		if (v in c.htmode)
			return v;

		cfg_rejected("phy.htmode", "HT20", "invalid htmode, dropping to HT20");
		return "HT20";
	}

	function phy_htmode_best(c, v) {
		let a;

		for (a in [ "HE", "VHT", "HT"]) {
			let htmode = sprintf("%s%s", a, v);

			if (htmode in c.htmode)
				return htmode;
		}

		cfg_rejected("phy.htmode", "", "invalid htwidth, dropping to HT20");
		return "HT20";
	}

	function phy_channel_verify(c, v) {
		if (v in c.channels)
			return v;

		cfg_rejected("phy.channel", c.channels[0], "invalid channel, falling back to %d", c.channels[0]);
		return c.channels[0];
	}

	let mimo = { "1x1": 1, "2x2": 3, "3x3": 8, "4x4": 15, "8x8": 255};

	function phy_get_mimo(request, max) {
		let v = mimo[request];

		if (!v || v > max) {
			cfg_rejected("phy.mimo", max, "invalid mimo setting, using %d", max);
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

		if (c.he_mac_capa)
			uci_defaults(v, { he_bss_color: 64, multiple_bssid: 0, ema: 0 });

		uci_set_options(u, v, [
			"disabled", "country", "beacon_int", "txpower",
			"chanbw", "require_mode", "legacy_rates",
			"he_bss_color", "multiple_bssid", "ema"
		]);
	}

	function phy_generate(wifi, x, rate) {
		for (let phy in cfg.phy) {
			if (phy.band in x.band === false)
				continue;

			phy_generate_options(wifi, x, phy.cfg);

			for (let ssid in cfg.ssid) {
				for (let band in ssid.band) {
					if (band != phy.band)
						continue;

					ssid_generate(wifi, ssid.cfg, x.uci, x, rate);
				}
			}

			return true;
		}

		return false;
	}

	function wifi_generate() {
		let wifi = {};
		let rate = {};

		if (!capab.wifi)
			return;

		cursor = uci.cursor();
		cursor.load("wireless");
		cursor.foreach("wireless", "wifi-device", function(d) {
			if (capab.wifi[d.path])
				capab.wifi[d.path]["uci"] = d[".name"];
		});

		for (let path in capab.wifi) {
			let phy = capab.wifi[path];

			if (!phy.uci)
				continue;

			if (phy_generate(wifi, phy, rate) === false)
				wifi[phy.uci] = { disabled: "1" };
		}

		uci_render("wireless", wifi);
		uci_render("ratelimit", rate);
	}

	wifi_generate();
%}

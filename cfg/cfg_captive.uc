{%
	function generate_captive() {
		let opennds = {"gatewayinterface": "br-captive", "enabled": 1};

		uci_defaults(cfg.captive, { "gatewayname": "uCentral", "gatewayfqdn": "ucentral.splash",
					   "maxclients": "64", "authidletimeout": 120, "uploadrate": 0,
					   "downloadrate": 0, "uploadquota": 0, "downloadquota": 0 });
		uci_set_options(opennds, cfg.captive, [ "enabled", "gatewayname", "gatewayfqdn", "maxclients",
							"authidletimeout", "uploadrate", "downloadrate",
							"uploadquota", "downloadquota" ]);
		uci_render("opennds", { "@opennds[-1]": opennds });
	}

	generate_captive();
%}

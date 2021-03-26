{%
	function generate_captive() {
		let opennds = {};

		uci_defaults(cfg.captive { "enabled": 0, "gatewayname": "uCentral", "gatewayfqdn": "ucentral.splash",
					   "maxclients": "64", "authidletimeout": 120, "uploadrate": 0,
					   "downloadrate": 0, "uploadquota": 0, "downloadquota": 0 };
		uci_set_options(opennds, cfg.captive, { "enabled", "gatewayname", "gatewayfqdn", "maxclients",
							"authidletimeout", "uploadrate", "downloadrate",
							"uploadquota", "downloadquota" });
		uci_render("opennds", { opennds });
	}

	generate_captive();
%}

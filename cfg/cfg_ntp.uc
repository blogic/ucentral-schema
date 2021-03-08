{%
	function generate_ntp() {
		let ntp = {};

		uci_set_option(ntp, cfg.ntp, "enabled");
		uci_set_option(ntp, cfg.ntp, "enable_server");
		uci_set_option(ntp, cfg.ntp, "server");

		uci_render("system", { ntp });
	}

	generate_ntp();
%}

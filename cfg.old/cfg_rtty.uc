{%
	function generate_rtty() {
		let x = {};
		uci_set_options(x, cfg.rtty, [ "enable", "host", "token", "port", "interface" ]);

		uci_render("rtty", { "@rtty[-1]": x });
	}

	generate_rtty();
%}

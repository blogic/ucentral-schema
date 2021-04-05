{%
	function generate_steer() {
		let steer = {};

		uci_set_options(steer, cfg.steer, [ "enabled", "network", "debug_level"]);
		uci_render("usteer", { "@usteer[-1]": steer });

		if (!cfg.steer.enabled || cfg.steer.network != "wan")
			return;

		let fw = {};

		uci_new_section(fw, "usteer_wan", "rule", {
			name: "Allow-uSteer-WAN",
			src: "wan",
			proto: "udp",
			target: "ACCEPT",
			dest_port: 16720
		});

		uci_render("firewall", fw);
	}

	generate_steer();
%}

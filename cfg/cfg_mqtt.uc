{%
	function generate_mqtt() {
		let mqtt = {};

		uci_defaults(cfg.mqtt, { enable: 0 });

		if (cfg.mqtt.enable == 1 && !uci_requires(cfg.log, [ "server", "port", "username", "password" ])) {
			cfg_error("invalid MQTT options");
			cfg.mqtt.enable = 0;
		}

		uci_set_options(mqtt, cfg.mqtt, [ "enable", "server", "port", "username", "password" ]);
		uci_render("umqtt", { mqtt });
	}

	generate_mqtt();
%}

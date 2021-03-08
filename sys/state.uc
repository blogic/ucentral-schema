{%
	let statefile_path = "/tmp/ucentral.state";

	let state = {
		uuid: time(),
		cfg_uuid: cfg.uuid
	};

	if (!length(stats)) {
		let cursor = uci.cursor();
		cursor.load("ustats");
		stats = cursor.get_all("ustats", "stats");
	}

	if (!ctx)
		ctx = ubus.connect();

	function ubus_call(statclass, name, object, method) {
		try {
			if (stats[statclass] == 1) {
				let tmp = ctx.call(object, method);

				if (length(tmp))
					state[name] = tmp;
				else
					warn("Statistics call %s/%s failed with status %s",
						object, method, ctx.error());
			}
		}
		catch(e) {
			warn("Exception while gathering stats: " + e);
		}
	}

	ubus_call("system", "system", "system", "info");
	ubus_call("wifiiface", "wifi-iface", "wifi", "iface");
	ubus_call("wifistation", "wifi-station", "wifi", "station");
	ubus_call("poe", "poe", "poe", "info");
	ubus_call("neighbours", "neighbours", "topology", "mac");
	ubus_call("traffic", "traffic", "topology", "port");

	if (stats.lldp == 1) {
		try {
			let lldp = fs.popen("lldpcli -f json show neighbors");

			if (lldp) {
				state.lldp = json(lldp.read("all")).lldp;
				lldp.close();
			}
			else {
				log("LLDP cli command failed: %s", fs.error());
			}
		}
		catch(e) {
			log("Failed to parse LLDP cli output: %s", e);
		}
	}

	if (stats.serviceprobe == 1) {
		try {
			include("./probe_services.uc");
		}
		catch(e) {
			log("Failed to invoke service probing: %s", e);
		}
	}

	ctx.call("ucentral", "send", { state });

	print(state);

	let f = fs.open(statefile_path, "w");

	if (f) {
		f.write(state);
		f.close();
	}
	else {
		log("Unable to open %s for writing: %s", statefile_path, fs.error());
	}
%}

{%
	let statefile_path = "/tmp/ucentral.state";

	let cursor = uci.cursor();
	let state = {};
	let msg = {
		uuid: cfg.uuid,
		serial: cursor.get("ucentral", "config", "serial")
	};

	if (!length(stats)) {
		cursor.load("ustats");
		stats = cursor.get_all("ustats", "stats");
	}
	if (!ctx)
		ctx = ubus.connect();

	if (!log)
		log = (fmt, ...args) => warn(sprintf(fmt + "\n", ...args));

	function ubus_call(statclass, name, object, method) {
		try {
			if (stats[statclass] == 1) {
				let tmp = ctx.call(object, method);

				if (length(tmp))
					state[name] = tmp;
				else if (!tmp)
					log("Statistics call %s/%s failed: %s", object, method, ctx.error());
			}
		}
		catch(e) {
			log("Exception while gathering stats: %s\n%s\n", e, e.stacktrace[0].context);
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
			log("Failed to parse LLDP cli output: %s\n%s\n", e, e.stacktrace[0].context);
		}
	}

	if (stats.serviceprobe == 1) {
		try {
			include("./probe_services.uc", {state});
		}
		catch(e) {
			log("Failed to invoke service probing: %s\n%s\n", e, e.stacktrace[0].context);
		}
	}


	msg.state = state;

	ctx.call("ucentral", "stats", msg);

	print(state);

	let f = fs.open(statefile_path, "w");

	if (f) {
		f.write(msg);
		f.close();
	}
	else {
		log("Unable to open %s for writing: %s", statefile_path, fs.error());
	}
%}

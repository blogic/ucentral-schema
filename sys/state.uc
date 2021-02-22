{%
state = {};
state.uuid = time();
state.cfg_uuid = cfg.uuid;

if (!length(stats)) {
	cursor = uci.cursor();
	cursor.load("ustats");
	stats = cursor.get_all("ustats", "stats");
}

ctx = ubus.connect();

function ubus_call(class, name, object, method) {
	try {
		if (stats[class] == 1) {
			local tmp = ctx.call(object, method);
			if (length(tmp))
				state[name] = tmp;
		}
	} catch(e) {
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
		lldp = fs.popen("lldpcli -f json show neighbors");
		state.lldp = json(lldp.read("all")).lldp;
	} catch(e) {
		warn("failed to scarpe lldp output " + e);
	}
}

if (stats.serviceprobe == 1) {
	try {
		include("./probe_services.uc");
	} catch(e) {
		warn("failed to invoke service probing " + e);
	}
}
ctx.call("ucentral", "send", {"state": state});

print(state);
f = fs.open("/tmp/ucentral.state");
f.write(state);
f.close();
%}

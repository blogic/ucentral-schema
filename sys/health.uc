{%
state = {
	wifi: {},
	serviceprobe: {},
	memory: {}
};

ctx = ubus.connect();

try {
	cursor = uci.cursor();
	cursor.load("wireless");
	wifi = cursor.get_all("wireless");

	wifi_state = ctx.call("wifi", "iface");

	function find_ssid(ssid) {
		for (let name, iface in wifi_state)
			if (ssid == iface.ssid)
				return 0;
		return 1;
	}

	for (name, iface in wifi) {
		if (iface[".type"] != "wifi-iface")
			continue;
		if (find_ssid(iface.ssid))
			state.wifi[iface.ssid] = 1;
	}
}
catch(e) {
	log("Failed to invoke wifi probing: %s\n%s\n", e, e.stacktrace[0].context);
}

try {
	memory = ctx.call("system", "info");
	memory = memory.memory;
	if (memory.available * 100 / memory.total <= 10)
		state.memory = memory;
}
catch(e) {
	log("Failed to invoke memory probing: %s\n%s\n", e, e.stacktrace[0].context);
}

try {
	include("./probe_services.uc");
}
catch(e) {
	log("Failed to invoke service probing: %s\n%s\n", e, e.stacktrace[0].context);
}

sanity = 100;
for (e in state)
	if (length(state[e]))
		sanity -= 10;

if (sanity == 100)
	state = {};

warn(printf("health check reports sanity of %d%%", sanity));
ctx.call("ucentral", "health", {sanity: sanity, data: state});
%}

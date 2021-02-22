{%
health = {};

cursor = uci.cursor();
cursor.load("wireless");
wifi = cursor.get_all("wireless");

ctx = ubus.connect();
state = ctx.call("wifi", "iface");

function find_ssid(ssid) {
	for (local name, iface in state)
		if (ssid == iface.ssid)
			return 0;
	return 1;
}

for (name, iface in wifi) {
	if (iface[".type"] != "wifi-iface")
		continue;
	if (!find_ssid(iface.ssid))
		health[iface.ssid] = 1;
}

if (length(health)) {
	ctx.call("ucentral", "send", {"uuid": time(), "error": "ssid did not start", "ssid": health});
	warn("ssids did not start " + health);
} else {
	ctx.call("ucentral", "log", {"msg": "wifi started successfully"});
	warn("wifi started successfully");
}
%}

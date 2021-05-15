#!/usr/bin/ucode
{%
let fs = require("fs");
let uci = require("uci");
let ubus = require("ubus");

state = {
	unit: {},
	interfaces: {}
};

let ctx = ubus.connect();
let interfaces = ctx.call("network.interface", "dump").interface;
let cursor = uci.cursor();
cursor.load("dhcp");
cursor.load("wireless");
let dhcp = cursor.get_all("dhcp");
let wifi_config = cursor.get_all("wireless");
let wifi_state = ctx.call("wifi", "iface");
let count = 0;

function find_ssid(ssid) {
	for (let name, iface in wifi_state)
		if (ssid == iface.ssid)
			return 0;
	return 1;
}

function radius_probe(server, port, secret)
{
	let f = fs.open("/tmp/radius.conf", "w");
	if (f) {
		f.write(sprintf("authserver %s:%d\n", server, port));
		f.write("servers /tmp/radius.servers\n");
		f.write("dictionary /etc/radli/dictionary\n");
		f.write("radius_timeout 3\n");
		f.write("radius_retries 1\n");
		f.write("bindaddr *\n");
		f.close();
	}

	let f = fs.open("/tmp/radius.servers", "w");
	if (f) {
		f.write(sprintf("%s %s\n", server, secret));
		f.close();
	}
	return system(['/usr/sbin/radiusprobe']);
}

for (let iface in interfaces) {
	let name = iface.interface;
	if (name == "loopback")
		continue;

	count++;

	let health = {};
	let ssid = {};
	let radius = {};
	let device = iface.l3_device;

	if (dhcp[name] || (iface.data && iface.data.leasetime)) {
		let rc = system(['/usr/sbin/dhcpdiscover', '-i', device, '-t', '5']);
		if (rc)
			health.dhcp = false;
	}

	let dns = iface["dns-server"];
	if (!length(dns) && iface["ipv4-address"] && iface["ipv4-address"][0])
		dns = [ iface["ipv4-address"][0]["address"] ];

	for (let ip in dns) {
		let rc = system(['/usr/sbin/dnsprobe', '-s', ip]);

		if (rc)
			health.dns = false
	}


	for (let k, iface in wifi_config) {
		if (iface[".type"] != "wifi-iface" || iface.network != name)
			continue;
		if (find_ssid(iface.ssid))
			ssid[iface.ssid] = false;
		if (iface.auth_server && iface.auth_port && iface.auth_secret)
			if (radius_probe(iface.auth_server, iface.auth_port, iface.auth_secret))
				radius[iface.ssid] = false;
	}

	if (length(ssid))
		health.ssids = ssid;

	if (length(radius))
		health.radius = radius;

	if (length(health))
		state.interfaces[name] = health;
}

try {
	memory = ctx.call("system", "info");
	memory = memory.memory;
	state.unit.memory =  100 - (memory.available * 100 / memory.total);
}
catch(e) {
	log("Failed to invoke memory probing: %s\n", e);
}

let errors = length(state.interfaces);
if (!errors)
	delete(state, "interfaces");

let sanity = 100 - (errors * 100 / count);

warn(printf("health check reports sanity of %d", sanity));
ctx.call("ucentral", "health", {sanity: sanity, data: state});
%}

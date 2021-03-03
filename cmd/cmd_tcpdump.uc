{%
let ctx = ubus.connect();
let cursor = uci.cursor();

cursor.load("ucentral");
serial = cursor.get("ucentral", "config", "serial");

if (!serial)
	return;

if (cmd.network) {
	let net = ctx.call(sprintf("network.interface.%s", cmd.network), "status");
	if (net && net.l3_device)
		cmd.iface = net.l3_device;
}

if (!cmd.iface) {
	ctx.call("ucentral", "log", {"msg": "failed to start tcpdump, unknown interface"});
	return;
}

if (!cmd.duration)
	cmd.duration = 30;

let filename = sprintf("/tmp/pcap-%s-%d", serial, time);
let ret = fs.popen(sprintf("/usr/sbin/tcpdump -c 1000 -G %d -W 1 -w %s -i %s",
		     cmd.duration, filename, cmd.iface));
if (ret) {
	ctx.call("ucentral", "log", {"msg": sprintf("tcpdump returned: %d", ret)});
	return;
}
ctx.call("ucentral", "log", {"msg": "tcpdump done, upload TBD"});
%}

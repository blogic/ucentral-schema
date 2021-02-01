{%
fail = {};
dhcp = {};
dns = {"localhost": ["127.0.0.1" ]};

function lookup_wan() {
	i = ctx.call("network.interface.wan", "status");
	if (i["dns-server"])
		dns.wan = i["dns-server"];
	if (i["l3_device"])
		dhcp.wan = i["l3_device"];
}

function lookup_ip(iface) {
	i = ctx.call("network.interface." + iface, "status");
	if (i["ipv4-address"] && i["ipv4-address"][0]) {
		dns[iface] = [];
		dns[iface][0] = i["ipv4-address"][0]["address"];
	}
	if (i["l3_device"])
		dhcp[iface] = i["l3_device"];
}

function service_probe() {
	lookup_wan();

	cursor = uci.cursor();
	cursor.load("dhcp");
	cursor.foreach("dhcp", "dhcp", function(d) {
		if (d.ignore == 1)
			return;
		lookup_ip(d.interface);
	});

	for (local iface, ips in dns) {
		local failed = 1;
		for (local ip in ips) {
			local ret = fs.popen(sprintf('/usr/sbin/dnsprobe -s %s', ip), 'r').close();
			if (ret)
				continue;
			failed = 0;
		}
		if (!failed)
			continue;
		if (fail.dns == null)
			fail.dns = {};
		fail.dns[iface] = ips;
	}

	for (local iface, dev in dhcp) {
		local ret = fs.popen(sprintf('/usr/sbin/dhcpdiscover -i %s -t 5', dev), 'r').close();
		if (!ret)
			continue;
		if (fail.dhcp == null)
			fail.dhcp = {};
		fail.dhcp[iface] = dev;
	}

	return fail;
}
services = service_probe();
if (length(services))
	state.serviceprobe = services;
%}

{%
	let fail = {},
	dhcp = {},
	dns = { localhost: [ "127.0.0.1" ] };

	function lookup_wan() {
		let i = ctx.call("network.interface.wan", "status");

		if (i["dns-server"])
			dns.wan = i["dns-server"];

		if (i["l3_device"])
			dhcp.wan = i["l3_device"];
	}

	function lookup_ip(iface) {
		let i = ctx.call("network.interface", "status", { interface: iface });

		if (i["ipv4-address"] && i["ipv4-address"][0])
			dns[iface] = [ i["ipv4-address"][0]["address"] ];

		if (i["l3_device"])
			dhcp[iface] = i["l3_device"];
	}

	function service_probe() {
		lookup_wan();

		let cursor = uci.cursor();

		cursor.load("dhcp");
		cursor.foreach("dhcp", "dhcp", function(d) {
			if (d.ignore != 1)
				lookup_ip(d.interface);
		});

		for (let iface, ips in dns) {
			let failed = true;

			for (let ip in ips) {
				let rc = system(['/usr/sbin/dnsprobe', '-s', ip]);

				if (rc == 0)
					failed = false;
			}

			if (!failed)
				continue;

			fail.dns = fail.dns || {};
			fail.dns[iface] = ips;
		}

		for (let iface, dev in dhcp) {
			let rc = system(['/usr/sbin/dhcpdiscover', '-i', dev, '-t', '5']);

			if (rc != 0) {
				fail.dhcp = fail.dhcp || {};
				fail.dhcp[iface] = dev;
			}
		}

		return fail;
	}

	let services = service_probe();

	if (length(services))
		state.serviceprobe = services;
%}

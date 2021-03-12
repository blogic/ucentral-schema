{%
	let serial = cursor.get("ucentral", "config", "serial");

	if (!serial)
		return;

	if (args.network) {
		let net = ctx.call("network.interface", "status", { interface: args.network });

		if (!net || !net.l3_device) {
			log("Unable to resolve logical interface %s", args.network);

			return;
		}

		args.iface = net.l3_device;
	}

	if (!match(args.iface, /^[^\/]+$/) || (args.iface != "any" && !fs.stat("/sys/class/net/" + args.iface))) {
		log("Invalid network device specified");

		return;
	}

	let duration = +args.duration || 30;
	let filename = sprintf("/tmp/pcap-%s-%d", serial, time());

	let rc = system([
		'/usr/sbin/tcpdump',
		'-c', '1000',
		'-W', '1',
		'-G', duration,
		'-w', filename,
		'-i', args.iface
	]);

	if (rc != 0) {
		log("tcpdump command exited with non-zero code %d", rc);

		return;
	}

	log("tcpdump command completed, upload TBD");

	fs.unlink(filename);
%}

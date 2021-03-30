{%
	let serial = cursor.get("ucentral", "config", "serial");

	if (!serial)
		return;

	if (args.network) {
		let net = ctx.call("network.interface", "status", { interface: args.network });

		if (!net || !net.l3_device) {
			result_json({
				"error": 1,
				"text": "Failed",
				"resultCode": 1,
				"resultText": sprintf("Unable to resolve logical interface %s", args.network)
			});

			return;
		}

		args.iface = net.l3_device;
	}

	if (!match(args.iface, /^[^\/]+$/) || (args.iface != "any" && !fs.stat("/sys/class/net/" + args.iface))) {
		result_json({
			"error": 1,
			"text": "Failed",
			"resultCode": 1,
			"resultText": "Invalid network device specified"
		});

		return;
	}

	let duration = +args.duration || 30;
	let packets = +args.packets || 1000;
	let filename = sprintf("/tmp/pcap-%s-%d", serial, time());

	let rc = system([
		'tcpdump',
		'-c', packets,
		'-W', '1',
		'-G', duration,
		'-w', filename,
		'-i', args.iface
	]);

	if (rc != 0) {
		result_json({
			"error": 1,
			"text": "Failed",
			"resultCode": rc,
			"resultText": "tcpdump command exited with non-zero code"
		});

		return;
	}

	let ctx = ubus.connect();
	ctx.call("ucentral", "upload", {file: filename, path: args.path, uuid: args.serial});

	fs.unlink(filename);

	result_json({
		"error": 0,
		"text": "Success",
		"resultCode": 0,
		"resultText": "Uploading file"
	});
%}

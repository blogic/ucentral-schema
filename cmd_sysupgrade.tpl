{%
	if (!cmd.url) {
		warn("usync-upgrade: invalid FW URL\n");
		return;
	}
	path = "/tmp/usync.upgrade";
	fs.popen(sprintf('wget %s -O %s', cmd.url, path), 'r').close();

	ctx = ubus.connect();
	fw = ctx.call("system", "validate_firmware_image", { "path": path });

	if (!fw.valid) {
		ctx = ubus.connect();
		ctx.call("usync", "log", {"error": "firmware file validation failed", "data": fw});
		warn("usync-upgrade: firmware file validation failed\n");
		return;
	}
	fs.popen(sprintf('/sbin/sysupgrade %s', path), 'r').close();
%}

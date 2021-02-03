{%
	if (!cmd.url) {
		warn("ucentral-upgrade: invalid FW URL\n");
		return;
	}
	path = "/tmp/ucentral.upgrade";
	fs.popen(sprintf('wget %s -O %s', cmd.url, path), 'r').close();

	ctx = ubus.connect();
	fw = ctx.call("system", "validate_firmware_image", { "path": path });

	if (!fw.valid) {
		ctx = ubus.connect();
		log = {"error": "firmware file validation failed", "data": fw};
		ctx.call("ucentral", "send", {"log": log});
		warn("ucentral-upgrade: firmware file validation failed\n");
		return;
	}

	let keep_redirector = "";
	if (cmd.keep_redirector) {
		keep_redirector = "-f /tmp/sysupgrade.tgz";
		fs.popen(sprintf('tar czf /tmp/sysupgrade.tgz /etc/config/ucentral /etc/ucentral/*.pem /etc/ucentral/*.crt /etc/ucentral/ucentral.active %s',
			 fs.readlink("/etc/ucentral/ucentral.active")), 'r').close();
	}

	ctx.call("ucentral", "log", {"msg": "upgrading fw"});
	fs.popen(sprintf('/etc/init.d/network stop'), 'r').close();
	fs.popen(sprintf('/sbin/sysupgrade %s %s', keep_redirector, path), 'r').close();
%}

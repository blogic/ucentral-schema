{%
	let image_path = "/tmp/ucentral.upgrade";

	if (!args.url) {
		log("No firmware URL provided");

		return;
	}

	let download_cmdline = [ 'wget', '-O', image_path, args.url ];
	let rc = system(download_cmdline);

	if (rc != 0) {
		log("Download command %s exited with non-zero code %d", download_cmdline, rc);

		return;
	}

	let validation_result = ctx.call("system", "validate_firmware_image", { path: image_path });

	if (!validation_result) {
		log("Validation call failed with status %s", ubus.error());

		return;
	}
	else if (!validation_result.valid) {
		ctx.call("ucentral", "send", {
			log: {
				error: "Firmware image validation failed",
				data: validation_result
			}
		});

		warn(sprintf("ucentral-upgrade: firmware file validation failed: %J\n", validation_result));

		return;
	}

	let archive_cmdline = [
		'tar', 'czf', '/tmp/sysupgrade.tgz',
		'/etc/config/ucentral',
		'/etc/ucentral/*.pem',
		'/etc/ucentral/*.crt'
	];

	if (args.keep_redirector) {
		let active_config = fs.readlink("/etc/ucentral/ucentral.active");

		if (active_config)
			push(archive_cmdline, '/etc/ucentral/ucentral.active', active_config);
		else
			log("Unable to determine active configuration: %s", fs.error());
	}

	let rc = system(archive_cmdline);

	if (rc != 0) {
		log("Archive command %s exited with non-zero code %d", archive_cmdline, rc);

		return;
	}

	let sysupgrade_cmdline = [
		'/sbin/sysupgrade',
		...(args.keep_redirector ? [ '-f', '/tmp/sysupgrade.tgz' ] : []),
		image_path
	];

	log("Upgrading firmware");

	system(['/etc/init.d/network', 'stop']);

	rc = system(sysupgrade_cmdline);

	if (rc != 0)
		log("System upgrade command %s exited with non-zero code %d", sysupgrade_cmdline, rc);
%}

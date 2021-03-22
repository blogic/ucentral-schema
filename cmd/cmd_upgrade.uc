{%
	let image_path = "/tmp/ucentral.upgrade";

	if (!args.uri) {
		result({
			"error": 2,
			"text": "No firmware URL provided" 
		});

		return;
	}

	let download_cmdline = [ 'wget', '-O', image_path, args.uri ];
	let rc = system(download_cmdline);

	if (rc != 0) {
		result({
			"error": 2,
			"text": sprintf("Download command %s exited with non-zero code %d", download_cmdline, rc)
		});

		return;
	}

	let validation_result = ctx.call("system", "validate_firmware_image", { path: image_path });

	if (!validation_result) {
		result({
			"error": 2,
			"text": sprintf("Validation call failed with status %s", ubus.error())
		});

		return;
	}
	else if (!validation_result.valid) {
		result({
			"error": 2,
			"text": "Firmware image validation failed",
			"data": sprintf("Archive command %s exited with non-zero code %d", archive_cmdline, rc)
		});

		warn(sprintf("ucentral-upgrade: firmware file validation failed: %J\n", validation_result));

		return;
	}

	let archive_cmdline = [
		'tar', 'czf', '/tmp/sysupgrade.tgz',
		'/etc/config/ucentral',
		'/etc/ucentral/cert.pem'
	];

	if (args.keep_redirector) {
		let active_config = fs.readlink("/etc/ucentral/ucentral.active");

		if (active_config)
			push(archive_cmdline, '/etc/ucentral/ucentral.active', active_config);
		else
			result({
				"error": 2,
				"text": sprintf("Unable to determine active configuration: %s", fs.error())
			});
	}

	let rc = system(archive_cmdline);

	if (rc != 0) {
		result({
			"error": 2,
			"text": sprintf("Archive command %s exited with non-zero code %d", archive_cmdline, rc)
		});

		return;
	}

	let sysupgrade_cmdline = [
		'sysupgrade',
		...(args.keep_redirector ? [ '-f', '/tmp/sysupgrade.tgz' ] : []),
		image_path
	];

	system(['/etc/init.d/network', 'stop']);

	rc = system(sysupgrade_cmdline);

	if (rc != 0)
		result({
			"error": 2,
			"text": sprintf("System upgrade command %s exited with non-zero code %d", sysupgrade_cmdline, rc)
		});
%}

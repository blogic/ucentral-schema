{%
	let reset_cmdline = [ 'jffs2reset', '-r', '-y' ];

	if (length(args) && args.keep_redirector) {
		let archive_cmdline = [
			'tar', 'czf', '/sysupgrade.tgz',
			'/etc/ucentral/*.pem',
			'/etc/ucentral/*.key',
			'/etc/ucentral/*.json',
			'/etc/ucentral/dev-id',
			'/etc/config/ucentral'
		];

		let active_config = fs.readlink("/etc/ucentral/ucentral.active");

		if (active_config)
			push(archive_cmdline, '/etc/ucentral/ucentral.active', active_config);
		else
			result({
				"error": 2,
				"text": sprintf("Unable to determine active configuration: %s", fs.error())
			});

		let rc = system(archive_cmdline);

		if (rc != 0) {
			result({
				"error": 2,
				"text": sprintf("Archive command %s exited with non-zero code %d", archive_cmdline, rc)
			});

			return;
		}

		push(reset_cmdline, '-k');
	}

	let rc = system(reset_cmdline);

	if (rc != 0)
		result({
			"error": 2,
			"text": sprintf("Reset command %s exited with non-zero code %d", reset_cmdline, rc)
		});
%}

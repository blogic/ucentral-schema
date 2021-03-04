{%
	let reset_cmdline = [ 'jffs2reset', '-r', '-y' ];

	if (args.keep_redirector) {
		let archive_cmdline = [
			'tar', 'czf', '/sysupgrade.tgz',
			'/etc/config/ucentral',
			'/etc/ucentral/*.pem',
			'/etc/ucentral/*.crt'
		];

		let active_config = fs.readlink("/etc/ucentral/ucentral.active");

		if (active_config)
			push(archive_cmdline, '/etc/ucentral/ucentral.active', active_config);
		else
			log("Unable to determine active configuration: %s", fs.error());

		let rc = system(archive_cmdline);

		if (rc != 0) {
			log("Archive command %s exited with non-zero code %d", archive_cmdline, rc);

			return;
		}

		push(reset_cmdline, '-k');
	}

	let rc = system(reset_cmdline);

	if (rc != 0)
		log("Reset command %s exited with non-zero code %d", reset_cmdline, rc);
%}

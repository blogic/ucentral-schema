{%
	let keep_redirector = "";

	if (cmd.keep_redirector) {
		keep_redirector = "-k";
		fs.popen(sprintf('tar czf /sysupgrade.tgz /etc/config/ucentral /etc/ucentral/*.pem /etc/ucentral/*.crt /etc/ucentral/ucentral.active %s',
			 fs.readlink("/etc/ucentral/ucentral.active")), 'r').close();
	}

	fs.popen(sprintf('jffs2reset -r -y %s', keep_redirector) , 'r');
%}

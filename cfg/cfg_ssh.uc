{%
	function generate_ssh() {
		let ssh = {};

		uci_defaults(cfg.ssh, { "Port": 22 });
		uci_set_options(ssh, cfg.ssh, ["enable", "Port", "RootPasswordAuth", "PasswordAuth"]);

		uci_render("dropbear", { "@dropbear[-1]": ssh });

		if (cfg.ssh.allow_wan) {
			let fw = {};
			uci_new_section(fw, "allow_ssh_wan", "rule", {
				name: "Allow-ssh-wan",
				src: "wan",
				port: cfg.ssh.Port,
				proto:"tcp",
				target: "ACCEPT"
			});
			uci_render("firewall", fw);
		}

		if (cfg.ssh.authorized_keys) {
			let fd = fs.open("/etc/dropbear/authorized_keys", "w");
			fd.write(cfg.ssh.authorized_keys);
			fd.close();
		} else {
			fs.unlink("/etc/dropbear/authorized_keys");
		}
	}

	generate_ssh();
%}

{%
function generate_ssh() {
	local ssh= {};

	uci_set_option(ssh, cfg.ssh, "enable");
	uci_set_option(ssh, cfg.ssh, "Port");

	uci_render("dropbear", { "@dropbear[-1]": ssh});
}

generate_ssh();
%}

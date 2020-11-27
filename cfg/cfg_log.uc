{%
function generate_log() {
	local log = {};

	uci_set_option(log, cfg.log, "log_size");

	if (uci_requires(cfg.log, [ "log_proto", "log_ip", "log_port" ])) {
		uci_set_options(log, cfg.log, [ "log_proto", "log_ip", "log_port", "log_hostname"  ]);
		log.log_remote = 1;
	}

	uci_render("system", { "@system[-1]": log});
}

generate_log();
%}

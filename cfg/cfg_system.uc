{%
function generate_system() {
	local system = {};

	uci_set_options(system, cfg.system, [ "hostname", "timezone" ]);
	uci_render("system", { "@system[-1]": system});
}

generate_system();
%}

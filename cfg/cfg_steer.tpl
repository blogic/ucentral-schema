{%
function generate_steer() {
	local steer = {};

	uci_set_options(steer, cfg.steer, [ "enabled", "network", "debug_level"]);
	uci_render("usteer", { "@usteer[-1]": steer});
}

generate_steer();
%}

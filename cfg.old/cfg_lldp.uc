{%
function generate_lldp() {
	let lldp = {};

	cfg.lldp.description = cfg.lldp.lldp_description;
	cfg.lldp.interface = [];
	uci_defaults(cfg.lldp, {
		enable_cdp: 0,
		enable_fdp: 0,
		enable_sonmp: 0,
		enable_edp: 0,
		description: "uCentral",
		lldp_location: "universe",
	});

	uci_set_options(lldp, cfg.lldp, [
		"enable_cdp", "enable_fdp", "enable_sonmp",
		"enable_edp", "description", "lldp_location",
		"interface"
	]);

	for (let k, v in cfg.network)
		if (v.cfg.lldp)
			push(cfg.lldp.interface, network_generate_name(v));

	uci_render("lldpd", { config: lldp });
}

generate_lldp();
%}

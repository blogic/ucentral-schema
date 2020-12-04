{%
function generate_lldp() {
	local lldp= {};

	cfg.description = cfg.lldp_description;
	uci_defaults(lldp, { "enable_cdp": 0, "enable_fdp": 0, "enable_sonmp": 0,
			     "enable_edp": 0, "description": "uCentral",
			     "lldp_location": "universe", "interface": ["lan"] } );

	uci_set_options(lldp, cfg.lldp, [ "enable_cdp", "enable_fdp", "enable_sonmp",
					  "enable_edp", "description", "lldp_location",
					  "interface"] );

	uci_render("lldpd", { "config": lldp});
}

generate_lldp();
%}

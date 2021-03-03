{%
function generate_stats() {
	let stats = {};

	uci_defaults(stats, { "interval": 0, "neighbours": 0, "traffic": 0,
			     "wifiiface": 0, "wifistation": 0, "pids": 0,
			     "serviceprobe": 0, "lldp": 0, "system": 0,
			     "poe": 0 } );

	cfg.stats.interval *= 60;
	uci_set_options(stats, cfg.stats, [ "interval", "neighbours", "traffic",
			     "wifiiface", "wifistation", "pids",
			     "serviceprobe", "lldp", "system",
			     "poe" ] );

	uci_render("ustats", { "stats": stats});
}

generate_stats();
%}

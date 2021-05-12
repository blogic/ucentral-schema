{%
function generate_mdns() {
	let mdns = {};

	cfg.mdns.network = [];
	for (let k, v in cfg.network)
		if (v.cfg.mdns)
			push(cfg.mdns.network, network_generate_name(v));

	uci_set_options(mdns, cfg.mdns, [ "network" ]);
	uci_render("umdns", { "@umdns[-1]": mdns });

	if (!("wan" in cfg.mdns.network))
		return;

	let fw = {};

	uci_new_section(fw, "umdns_wan", "rule", {
		name: "Allow-uMDNS-WAN",
		src: "wan",
		proto: "udp",
		target: "ACCEPT",
		dest_port: 5353
	});

	uci_render("firewall", fw);
}

generate_mdns();
%}

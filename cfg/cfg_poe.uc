{%
function generate_poe() {
	let poe = {};

	for (let k, v in cfg.poe.ports)
		poe["port" + (k + 1)] = v;
	uci_render("poe", { "poe": poe});
}

generate_poe();
%}

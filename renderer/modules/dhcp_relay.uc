{%

"use strict";

let dhcp_relay = {
	state: {
		"AP-MAC": "%a",
		"AP-MAC-Hex": "%A",
		"Client-MAC": "%c",
		"Client-MAC-Hex": "%C",
		"Interface": "%i"
	},

	init: function() {
		cursor.load("system");

		let system = cursor.get_all("system", "@system[-1]");
		this.state.Name = (system && system.hostname) ? system.hostname : "unknown";
		this.state.Location = (system && system.notes) ? system.notes : "unknown";
		this.state["VLAN-Id"] = interface.vlan.id;
		this.state.Model = capab.compatible || "unknown";
		this.state.SSID = (interface.ssids && interface.ssids[0].name) ? interface.ssids[0].name : "unknown";
		this.state.Crypto = "unknown";
	},

	replace: function(str) {
		let subst = this.state;

		return replace(str, /\{([^{}]+)\}/g, (m, var) => {
    			return subst[var] || 'unknown';
		});
	}
};
%}

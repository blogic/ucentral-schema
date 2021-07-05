{%

"use strict";

return {
	state: {},

	set_enabled: function(name, state) {
		this.state[name] = state ? true : false;
	},

	is_present: function(name) {
		return length(fs.stat("/etc/init.d/" + name)) > 0;
	},

	lookup_interfaces: function(service) {
		let interfaces = [];

		for (let interface in state.interfaces) {
			if (!interface.services || index(interface.services, service) < 0)
				continue;
			push(interfaces, interface);
		}

		return interfaces;
	},

	lookup_ssids: function(service) {
		let ssids = [];

		for (let interface in state.interfaces) {
			if (!interface.ssids)
				continue;
			for (let ssid in interface.ssids) {
				if (!ssid.services || index(ssid.services, service) < 0)
					continue;
				push(ssids, ssid);
			}
		}

		return ssids;
	},

	lookup_services: function() {
		let rv = [];

		for (let incfile in fs.glob(topdir + '/templates/services/*.uc')) {
			let m = match(incfile, /^.+\/([^\/]+)\.uc$/);

			if (m)
				push(rv, m[1]);
		}

		return rv;
	},

	lookup_metrics: function() {
		let rv = [];

		for (let incfile in fs.glob(topdir + '/templates/metric/*.uc')) {
			let m = match(incfile, /^.+\/([^\/]+)\.uc$/);

			if (m)
				push(rv, m[1]);
		}

		return rv;
	}
};


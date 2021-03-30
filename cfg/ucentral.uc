{%
	ctx = ubus.connect();
	let rejected = [];

	let scope = {
		rejected,

		cfg_rejected: function(parameter, substitution, fmt, ...args) {
			let reason = sprintf(fmt, ...args);
			push(rejected, {parameter, substitution, reason});
		},

		cfg_error: function(fmt, ...args) {
			let msg = sprintf(fmt, ...args);

			warn(msg + "\n");

			ctx.call("ucentral", "log", { msg });
		},

		uci_defaults: function(o, d) {
			for (let k, v in d)
				if (!o[k])
					o[k] = v;
		},

		uci_requires: function(o, d) {
			for (let k, v in d)
				if (!o[v])
					return false;
			return true;
		},

		uci_render: function(file, obj) {
			let esc = (s) => replace(s, "'", "'\\''");

			for (let sid, section in obj) {
				if (section['.type'])
					printf("set %s.%s='%s'\n", file, sid, esc(section['.type']));

				for (let option, value in section) {
					if (index(option, '.') == 0)
						continue;

					if (type(value) == 'array') {
						printf("del %s.%s.%s\n", file, sid, option);

						for (let i, v in value)
							printf("add_list %s.%s.%s='%s'\n", file, sid, option, esc(v));
					}
					else if (value == nil) {
						printf("del %s.%s.%s\n", file, sid, option);
					}
					else {
						printf("set %s.%s.%s='%s'\n", file, sid, option, esc(value));
					}
				}
			}
		},

		uci_new_section: function(x, name, type, vals) {
			x[name] = x[name] || {};
			x[name][".type"] = type;

			if (vals)
				for (let k, v in vals)
					x[name][k] = v;

			return x[name];
		},

		uci_set_option: function(obj, cfg, key) {
			if (exists(cfg, key))
				obj[key] = cfg[key];
		},

		uci_set_options: function(obj, cfg, key) {
			for (let k, v in key)
				uci_set_option(obj, cfg, v);
		}
	};

	let fails = {};

	for (let key in cfg) {
		if (key in ["uuid", "ssid", "station", "wifi-vlan"])
			continue;

		let file = sprintf("/usr/share/ucentral/cfg_%s.uc", key);
		let stat = fs.stat(file);

		if (stat === null || stat.type != "file")
			continue;

		try {
			include(file, scope);
		}
		catch (e) {
			fails[key] = { ...e };

			warn(sprintf("Exception while generating %s: %s\n%s\n",
				key, e, e.stacktrace[0].context));
		}
	}

	if (length(rejected))
		ctx.call("ucentral", "rejected", {rejected});
	if (length(fails)) {
		ctx.call("ucentral", "send", {
			method: "log",
			params: {
				log: "Failed to apply configuration",
				data: fails
			}
		});
		exit(1);
	}
%}

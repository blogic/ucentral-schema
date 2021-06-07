{%
// UCI batch output master template

"use strict";

let uci = require("uci");
let ubus = require("ubus");
let fs = require("fs");

let cursor = uci ? uci.cursor() : null;
let conn = ubus ? ubus.connect() : null;

let capabfile = fs.open("/etc/ucentral/capabilities.json", "r");
let capab = capabfile ? json(capabfile.read("all")) : null;

assert(cursor, "Unable to instantiate uci");
assert(conn, "Unable to connect to ubus");
assert(capab, "Unable to load capabilities");

let topdir = sourcepath(0, true);

// Formats a given input value as uci boolean value.
function b(val) {
	return val ? '1' : '0';
}

// Formats a given input value as single quoted string, honouring uci
// specific escaping semantics.
function s(str) {
	if (str === null || str === '')
		return '';

	return sprintf("'%s'", replace(str, /'/g, "'\\''"));
}

// Attempts to include a file, catching potential exceptions
function tryinclude(path, scope) {
	if (!match(path, /^[A-Za-z0-9_\/-]+\.uc$/)) {
		warn("Refusing to handle invalid include path '%s'", path);
		return;
	}

	let parent_path = sourcepath(1, true);

	assert(parent_path, "Unable to determine calling template path");

	try {
		include(parent_path + "/" + path, scope);
	}
	catch (e) {
		warn("Unable to include path '%s': %s\n%s", path, e, e.stacktrace[0].context);
	}
}

function discover_ports() {
	let roles = {};

	/* Derive ethernet port names and roles from default config */
	for (let role, spec in capab.network) {
		for (let i, ifname in spec) {
			role = uc(role);
			push(roles[role] = roles[role] || [], {
				netdev: ifname,
				index: i
			});
		}
	}

	/* Sort ports in each role group according to their index, then normalize
	 * names into uppercase role name with 1-based index suffix in case of multiple
	 * ports or just uppercase role name in case of single ports */
	let rv = {};

	for (let role, ports in roles) {
		switch (length(ports)) {
		case 0:
			break;

		case 1:
			rv[role] = ports[0];
			break;

		default:
			map(sort(ports, (a, b) => (a.index - b.index)), (port, i) => {
				rv[role + (i + 1)] = port;
			});
		}
	}

	return rv;
}


let wiphy = {
	phys: conn.call("wifi", "phy"),

	lookup_by_band: function(band) {
		for (let path, phy in this.phys) {
			if (!(band in phy.band))
				continue;

			let sid = null;

			cursor.load("wireless");
			cursor.foreach("wireless", "wifi-device", (s) => {
				if (s.path == path) {
					sid = s['.name'];

					return false;
				}
			});

			if (sid) {
				phy.section = sid;

				return phy;
			}
		}

		return null;
	},

	allocate_ssid_section_id: function(phy) {
		phy.networks = ++phy.networks || 1;

		assert(phy.section, "Radio has no related uci section");

		return phy.section + 'net' + phy.networks;
	}
};

let ethernet = {
	ports: discover_ports(),

	lookup_by_interface_spec: function(interface) {
		// Gather the glob patterns in all `ethernet: [ { select-ports: ... }]` specs,
		// dedup them and turn them into one global regular expression pattern, then
		// match this pattern against all known system ethernet ports, remember the
		// related netdevs and return them as sorted, deduplicated array.
		let globs = {};
		map(interface.ethernet, eth => map(eth.select_ports, glob => globs[glob] = true));

		let re = regexp('^(' + join('|', map(keys(globs), glob => {
			replace(glob, /[].*+?^${}()|[\\]/g, m => {
				(m == '*') ? '.*' : ((m == '?') ? '.' : '\\' + m)
			})
		})) + ')$');

		let matched = {};

		for (let name, spec in this.ports) {
			if (match(name, re)) {
				if (spec.netdev)
					matched[spec.netdev] = true;
				else
					warn("Not implemented yet: mapping switch port to netdev");
			}
		}

		return sort(keys(matched));
	},

	is_single_config: function(interface) {
		let ipv4_mode = interface.ipv4 ? interface.ipv4.addressing : 'none';
		let ipv6_mode = interface.ipv6 ? interface.ipv6.addressing : 'none';

		return (
			(ipv4_mode == 'none') || (ipv6_mode == 'none') ||
			(ipv4_mode == 'static' && ipv6_mode == 'static')
		);
	},

	calculate_name: function(interface) {
		let vid = interface.vlan ? interface.vlan.id : '';

		if (interface.captive)
			return 'captive';

		if (interface.tunnel)
			return 'tunnel';

		return (interface.role == 'upstream' ? 'up' : 'down') + vid;
	},

	calculate_names: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? [ name ] : [ name + '_4', name + '_6' ];
	},

	calculate_ipv4_name: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? name : name + '_4';
	},

	calculate_ipv6_name: function(interface) {
		let name = this.calculate_name(interface);

		return this.is_single_config(interface) ? name : name + '_6';
	}
};

let ipcalc = {
	used_prefixes: [],

	convert_bits_to_mask: function(bits, v6) {
		let width = v6 ? 128 : 32,
		    mask = [];

		assert(bits <= width, "Invalid bit length");

		bits = width - bits;

		for (let i = width / 8; i > 0; i--) {
			let b = (bits < 8) ? bits : 8;
			mask[i - 1] = ~((1 << b) - 1) & 0xff;
			bits -= b;
		}

		return mask;
	},

	apply_mask: function(addr, mask) {
		assert(length(addr) == length(mask), "Incompatible mask");

		return map(addr, (byte, i) => byte & mask[i]);
	},

	is_intersecting_prefix: function(addr1, bits1, addr2, bits2) {
		assert(length(addr1) == length(addr2), "Incompatible addresses");

		let mask = this.convert_bits_to_mask((bits1 < bits2) ? bits1 : bits2, length(addr1) == 16);

		for (let i = 0; i < length(addr1); i++)
			if ((addr1[i] & mask[i]) != (addr2[i] & mask[i]))
				return false;

		return true;
	},

	add_amount: function(addr, amount) {
		for (let i = length(addr); i > 0; i--) {
			let t = addr[i - 1] + amount;
			addr[i - 1] = t & 0xff;
			amount = t >> 8;
		}

		return addr;
	},

	reserve_prefix: function(addr, mask) {
		for (let i = 0; i < length(this.used_prefixes); i += 2) {
			let addr2 = this.used_prefixes[i + 0],
			    mask2 = this.used_prefixes[i + 1];

			if (length(addr2) != length(addr))
				continue;

			if (this.is_intersecting_prefix(addr, mask, addr2, mask2))
				return false;
		}

		push(this.used_prefixes, addr, mask);

		return true;
	},

	generate_prefix: function(state, template, ipv6) {
		let prefix = match(template, /^(auto|[0-9a-fA-F:.]+)\/([0-9]+)$/);

		if (prefix && prefix[1] == 'auto') {
			assert(state.globals && state.globals[ipv6 ? 'ipv6_network' : 'ipv4_network'],
				"No global prefix pool configured");

			let pool = match(state.globals[ipv6 ? 'ipv6_network' : 'ipv4_network'], /^([0-9a-fA-F:.]+)\/([0-9]+)$/);

			assert(prefix[2] >= pool[2],
				"Interface " + (ipv6 ? "IPv6" : "IPv4") + " prefix size exceeds available allocation pool size");

			let available_prefixes = 1 << (prefix[2] - pool[2]),
			    prefix_mask = this.convert_bits_to_mask(prefix[2], ipv6),
			    address_base = iptoarr(pool[1]);

			for (let offset = 0; offset < available_prefixes; offset++) {
				if (this.reserve_prefix(address_base, prefix[2])) {
					this.add_amount(address_base, 1);

					return arrtoip(address_base) + '/' + prefix[2];
				}

				for (let i = length(address_base), carry = 1; i > 0; i--) {
					let t = address_base[i - 1] + (~prefix_mask[i - 1] & 0xff) + carry;
					address_base[i - 1] = t & 0xff;
					carry = t >> 8;
				}
			}

			die("No prefix of size /" + prefix[2] + " available");
		}

		return template;
	}
};

let services = {
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
		this.state["VLAN-Id"] = (interface.vlan ? interface.vlan.id : "0") || "0";
		this.state.Model = capab.compatible || "unknown";
		this.state.SSID = (interface.ssid && interface.ssid[0].name) ? interface.ssid[0].name : "unknown";
		this.state.Crypto = "unknown";
	},

	replace: function(str) {
		return replace(str, /\{(.+?)\}/g, (m, var) => {
    			return this.state[var];
		});
	}
};

return {
	render: function(state, logs) {
		logs = logs || [];

		return render('templates/toplevel.uc', {
			b,
			s,
			tryinclude,
			state,
			wiphy,
			ethernet,
			ipcalc,
			services,
			dhcp_relay,
			location: '/',
			fs,
			capab,

			warn: (fmt, ...args) => push(logs, sprintf("[W] (In %s) ", location || '/') + sprintf(fmt, ...args)),
			info: (fmt, ...args) => push(logs, sprintf("[!] (In %s) ", location || '/') + sprintf(fmt, ...args))
		});
	},

	services_state: function() {
		return services.state;
	}
};

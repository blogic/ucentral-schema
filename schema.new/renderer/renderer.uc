{%
// UCI batch output master template

"use strict";

let uci = require("uci");
let ubus = require("ubus");

let cursor = uci ? uci.cursor() : null;
let conn = ubus ? ubus.connect() : null;

assert(cursor, "Unable to instantiate uci");
assert(conn, "Unable to connect to ubus");

// Formats a given input value as uci boolean value.
function b(val) {
	return val ? '1' : '0';
}

// Formats a given input value as single quoted string, honouring uci
// specific escaping semantics.
function s(str) {
	if (s === null || s === '')
		return '';

	return sprintf("'%s'", replace(str, /'/g, "'\\''"));
}

function discover_ports() {
	let roles = {};

	/* XXX: remove me */
	let capab = {
		network: {
			"lan" : {
				"ifname" : "lan1 lan2 lan3 lan4",
				"macaddr" : "00:11:22:f5:37:d3",
				"protocol" : "static"
			},
			"wan" : {
				"ifname" : "wan",
				"macaddr" : "00:11:22:f5:37:d2",
				"protocol" : "dhcp"
			}
		}
	};

	/* Derive ethernet port names and roles from swconfig switch */
	if (type(capab.switch) == "object") {
		for (let switchname, switchspec in capab.switch) {
			if (type(switchspec) == "object" && type(switchspec.ports) == "array") {
				for (let portspec in switchspec.ports) {
					if (type(portspec) == "object" && exists(portspec, "num") && exists(portspec, "role")) {
						// XXX: check if we need to remember more properties to (re)construct
						// swconfig VLAN settings later...
						let role = uc(portspec.role);
						push(roles[role] = roles[role] || [], {
							switch: switchname,
							port: portspec.num,
							index: (type(portspec.index) == "int") ? portspec.index : portspec.num
						});
					}
				}
			}
		}
	}

	/* Derive ethernet port names and roles from DSA default config */
	else {
		for (let role, spec in capab.network) {
			if (type(spec) == "object" && type(spec.ifname) == "string") {
				for (let i, ifname in split(spec.ifname, /\s+/)) {
					if (ifname != "") {
						role = uc(role);
						push(roles[role] = roles[role] || [], {
							netdev: ifname,
							index: i
						});
					}
				}
			}
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
			if (phy.section)
				continue;

			// XXX: Remove this once the schema is updated
			if (band in ["5Gl", "5Gu"])
				band = "5G";

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

return {
	render: function(state, logs) {
		logs = logs || [];

		return render('templates/toplevel.uc', {
			b,
			s,
			state,
			wiphy,
			ethernet,
			ipcalc,

			warn: (fmt, ...args) => push(logs, "[W] " + sprintf(fmt, ...args)),
			info: (fmt, ...args) => push(logs, "[!] " + sprintf(fmt, ...args))
		});
	}
};

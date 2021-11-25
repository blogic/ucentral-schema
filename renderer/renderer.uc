{%
// UCI batch output master template

/**
 * @name uCentral
 * @type class
 * @classdesc
 *
 * This is the uCentral base class containing all relevant helper functions.
 * It is automatically instantiated and there is no global accessor.
 * foo
 */

"use strict";

let uci = require("uci");
let ubus = require("ubus");
let fs = require("fs");

let cursor = uci ? uci.cursor() : null;
let conn = ubus ? ubus.connect() : null;

let capabfile = fs.open("/etc/ucentral/capabilities.json", "r");
let capab = capabfile ? json(capabfile.read("all")) : null;

let serial = cursor.get("ucentral", "config", "serial");

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


/**
 * @name wiphy
 * @type class
 * @hideconstructor
 * @classdesc
 *
 * This is the wireless PHY base class. It is automatically instantiated and
 * accessible using the global 'wiphy' variable.
 */

let wiphy = {
	/**
	 * @name phys
	 * @instance
	 * @memberof wiphy
	 * This function returns a list of all available PHYs including
	 * the relevant data describing their properties and capabilities
	 * such as HT Modes, channels, ...
	 *
	 * @returns {Array}
	 * Returns an array of all available PHYs.
	 */
	phys: conn.call("wifi", "phy"),

	/**
	 * Lookup up the range of valid frequencies for a specific wireless band
	 *
	 * @param {string} wireless band
	 *
	 * @returns {(number|Array)}
	 * Returns and array containing the lowest and highest valid frequency
	 * for a specific wireless band.
	 */
	band_freqs: {
		'2G':       [  2412,  2484 ],
		'5G':       [  5160,  5885 ],
		'5G-lower': [  5160,  5340 ],
		'5G-upper': [  5480,  5885 ],
		'6G':       [  5925,  7125 ],
		'60G':		[ 58320, 69120 ]
	},

	/**
	 * Lookup up the range of valid channels for a specific wireless band
	 *
	 * @param {string} wireless band
	 *
	 * @returns {(number|Array)}
	 * Returns and array containing the lowest and highest valid channel
	 * for a specific wireless band.
	 */
	band_channels: {
		'2G': [ 1, 14 ],
		'5G': [ 7, 196 ],
		'5G-lower': [ 7, 68 ],
		'5G-upper': [ 96, 177 ],
		'6G': [ 200, 600 ], // FIXME
		'60G': [ 1, 6 ]
	},

	/**
	 * Convert a wireless channel to a wireless frequency
	 *
	 * @param {string} wireless band
	 * @param {number} channel
	 *
	 * @returns {number}
	 * Returns the coverted wireless frequency for this specific
	 * channel.
	 */
	channel_to_freq: function(band, channel) {
		if (band == '2G' && channel >= 1 && channel <= 13)
			return 2407 + channel * 5;
		else if (band == '2G' && channel == 14)
			return 2484;
		else if (band == '5G' && channel >= 7 && channel <= 177)
			return 5000 + channel * 5;
		else if (band == '5G' && channel >= 183 && channel <= 196)
			return 4000 + channel * 5;
		else if (band == '60G' && channel >= 1 && channel <= 6)
			return 56160 + channel * 2160;

		return null;
	},

	/**
	 * Convert the unique sysfs path describing a wireless PHY to
	 * the corresponding UCI section name
	 *
	 * @param {string} path
	 *
	 * @returns {string}
	 * Returns the UCI section name of a specific PHY
	 */
	path_to_section: function(path) {
		let sid = null;

		cursor.load("wireless");
		cursor.foreach("wireless", "wifi-device", (s) => {
			if (s.path == path) {
				sid = s['.name'];

				return false;
			}
		});

		return sid;
	},

	/**
	 * Get a list of all wireless PHYs for a specific wireless band
	 *
	 * @param {string} band
	 *
	 * @returns {(string|Array}}
	 * Returns an array of all wireless PHYs for a specific wireless
	 * band.
	 */
	lookup_by_band: function(band) {
		let baseband = band;
		let phys = [];

		if (band in ['5G-lower', '5G-upper'])
			baseband = '5G';

		for (let path, phy in this.phys) {
			if (!(baseband in phy.band))
				continue;

			let phy_min_freq, phy_max_freq;

			if (phy.frequencies) {
				phy_min_freq = min(...phy.frequencies);
				phy_max_freq = max(...phy.frequencies);
			}
			else {
				/* NB: this code is superfluous once ubus call wifi phy reports
				       supported frequencies directly */

				let min_ch = max(min(...phy.channels), this.band_channels[band][0]),
				    max_ch = min(max(...phy.channels), this.band_channels[band][1]);

				phy_min_freq = this.channel_to_freq(baseband, min_ch);
				phy_max_freq = this.channel_to_freq(baseband, max_ch);

				if (phy_min_freq === null) {
					warn("Unable to map channel %d in band %s to frequency", min_ch, baseband);
					continue;
				}

				if (phy_max_freq === null) {
					warn("Unable to map channel %d in band %s to frequency", max_ch, baseband);
					continue;
				}
			}

			/* phy's frequency range does not overlap with band's frequency range, skip phy */
			if (phy_max_freq < this.band_freqs[band][0] || phy_min_freq > this.band_freqs[band][1])
				continue;

			let sid = this.path_to_section(path);

			if (sid)
				push(phys, { ...phy, section: sid });
		}

		return phys;
	},

	allocate_ssid_section_id: function(phy) {
		phy.networks = ++phy.networks || 1;

		assert(phy.section, "Radio has no related uci section");

		return phy.section + 'net' + phy.networks;
	}
};

/**
 * @name ethernet
 * @type class
 * @hideconstructor
 * @classdesc
 *
 * This is the ethernet base class. It is automatically instantiated and
 * accessible using the global 'ethernet' variable.
 */

let ethernet = {
	ports: discover_ports(),

	/**
	 * Get a list of all wireless PHYs for a specific wireless band
	 *
	 * @param {string} band
	 *
	 * @returns {(string|Array}}
	 * Returns an array of all wireless PHYs for a specific wireless
	 * band.
	 */
	lookup: function(globs) {
		let matched = {};

		for (let glob, tag_state in globs) {
			for (let name, spec in this.ports) {
				if (wildcard(name, glob)) {
					if (spec.netdev)
						matched[spec.netdev] = tag_state;
					else
						warn("Not implemented yet: mapping switch port to netdev");
				}
			}
		}

		return matched;
	},

	lookup_by_interface_vlan: function(interface) {
		// Gather the glob patterns in all `ethernet: [ { select-ports: ... }]` specs,
		// dedup them and turn them into one global regular expression pattern, then
		// match this pattern against all known system ethernet ports, remember the
		// related netdevs and return them.
		let globs = {};
		map(interface.ethernet, eth => map(eth.select_ports, glob => globs[glob] = eth.vlan_tag));

		return this.lookup(globs);
	},

	lookup_by_interface_spec: function(interface) {
		return sort(keys(this.lookup_by_interface_vlan(interface)));
	},

	lookup_by_select_ports: function(select_ports) {
		let globs = {};
		map(select_ports, glob => globs[glob] = true);

		return sort(keys(this.lookup(globs)));
	},

	lookup_by_ethernet: function(ethernets) {
		let result = [];

		for (let ethernet in ethernets)
			result = [ ...result,  ...this.lookup_by_select_ports(ethernet.select_ports) ];
		return result;
	},

	reserve_port: function(port) {
		delete this.ports[port];
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
		let vid = interface.vlan.id;

		return (interface.role == 'upstream' ? 'up' : 'down') + interface.index + 'v' + vid;
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
	},

	has_vlan: function(interface) {
		return interface.vlan && interface.vlan.id;
	},

	port_vlan: function(interface, port) {
		if (port == "tagged")
			return ':t';
		if (port == "un-tagged")
			return '';
		return ((interface.role == 'upstream') && this.has_vlan(interface)) ? ':t' : '';
	},

	find_interface: function(role, vid) {
		for (let interface in state.interfaces)
			if (interface.role == role &&
			    interface.vlan.id == vid)
				return this.calculate_name(interface);
		return '';
	},

	get_interface: function(role, vid) {
		for (let interface in state.interfaces)
			if (interface.role == role &&
			    interface.vlan.id == vid)
				return interface;
		return null;
	},

	get_speed: function(dev) {
		let fp = fs.open(sprintf("/sys/class/net/%s/speed", dev));
		if (!fp)
			return 1000;
		let speed = fp.read("all");
		fp.close();
		return +speed;
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

	lookup_ethernet: function(service) {
		let ethernets = [];

		for (let ethernet in state.ethernet) {
			if (!ethernet.services || index(ethernet.services, service) < 0)
				continue;
			push(ethernets, ethernet);
		}

		return ethernets;
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

let local_profile = {
	get: function() {
		let profile_file = fs.open("/etc/ucentral/profile.json");

		if (profile_file) {
			let profile = json(profile_file.read("all"));

			profile_file.close();

			return profile;
		}
		return null;
	}
};

let files = {
	files: {},
	basedir: '/tmp/ucentral',

	escape: function(s) {
		return replace(s, /[~\/]/g, m => (m == '~' ? '~0' : '~1'));
	},

	add_named: function(path, content) {
		if (index(path, '/') != 0)
			path = this.basedir + '/' + path;

		this.files[path] = content;
	},

	add_anonymous: function(location, name, content) {
		let path = this.basedir + '/' + this.escape(location) + '/' + this.escape(name);

		this.files[path] = content;

		return path;
	},

	purge: function(logs, dir) {
		if (dir == null)
			dir = this.basedir;

		let d = fs.opendir(dir);

		if (d) {
			let e;

			while ((e = d.read()) != null) {
				if (e == '.' || e == '..')
					continue;
				let p = dir + '/' + e,
				    s = fs.lstat(p);

				if (s == null)
					push(logs, sprintf("[W] Unable to lstat() path '%s': %s", p, fs.error()));
				else if (s.type == 'directory')
					this.purge(logs, p);
				else if (!fs.unlink(p))
					push(logs, sprintf("[W] Unable to unlink() path '%s': %s", p, fs.error()));
			}

			d.close();

			if (dir != this.basedir && !fs.rmdir(dir))
				push(logs, sprintf("[W] Unable to rmdir() path '%s': %s", dir, fs.error()));
		}
		else {
			push(logs, sprintf("[W] Unable to opendir() path '%s': %s", dir, fs.error()));
		}
	},

	mkdir_path: function(logs, path) {
		assert(index(path, '/') == 0, "Expecting absolute path");

		let segments = split(path, '/'),
		    tmppath = shift(segments);

		for (let i = 0; i < length(segments) - 1; i++) {
			tmppath += '/' + segments[i];

			let s = fs.stat(tmppath);

			if (s != null && s.type == 'directory')
				continue;

			if (fs.mkdir(tmppath))
				continue;

			push(logs, sprintf("[E] Unable to mkdir() path '%s': %s", tmppath, fs.error()));

			return false;
		}

		return true;
	},

	write: function(logs) {
		let success = true;

		for (let path, content in this.files) {
			if (!this.mkdir_path(logs, path)) {
				success = false;
				continue;
			}

			let f = fs.open(path, "w");

			if (f) {
				f.write(content);
				f.close();
			}
			else {
				push(logs, sprintf("[E] Unable to open() path '%s' for writing: %s", path, fs.error()));
				success = false;
			}
		}

		return success;
	}
};

let shell = {
	password: function() {
		if (length(fs.stat("/tmp/ucentral.pwd")))
			return;
		let math = require("math");
		let passwd = "";
		for (let i = 0; i < 32; i++) {
			let r = math.rand() % 62;
			if (r < 10)
				passwd += r;
		else if (r < 36)
				passwd += sprintf("%c", 55 + r);
			else
				passwd += sprintf("%c", 61 + r);
		}
		system("(echo " + passwd + "; sleep 1; echo " + passwd + ") | passwd root");
		system("touch /tmp/ucentral.pwd");
		conn.call("ucentral", "password", { passwd });
	}
};

let routing_table = {
	used_tables: {},

	next: 1,

	get: function(id) {
		if (!this.used_tables[id])
			this.used_tables[id] = this.next++;
		return this.used_tables[id];
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
			local_profile,
			location: '/',
			cursor,
			capab,
			files,
			shell,
			routing_table,
			serial,

			warn: (fmt, ...args) => push(logs, sprintf("[W] (In %s) ", location || '/') + sprintf(fmt, ...args)),
			info: (fmt, ...args) => push(logs, sprintf("[!] (In %s) ", location || '/') + sprintf(fmt, ...args))
		});
	},

	write_files: function(logs) {
		logs = logs || [];

		files.purge(logs);

		return files.write(logs);
	},

	files_state: function() {
		return files.files;
	},

	services_state: function() {
		return services.state;
	}
};

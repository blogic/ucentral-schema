{%

"use strict";

return {
	ports: discover_ports() {
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
	},

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
	}
};
%}

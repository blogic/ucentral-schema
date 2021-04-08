{%
	function have_dhcpv6_relay_interfaces() {
		for (let net in cfg.network)
			if (net.cfg && net.cfg.ipv6_dhcpmode == "relay")
				return true;

		return false;
	}

	function ipv6_default_mode_for_role(role) {
		switch (role) {
		case 'wan':
			return 'upstream';

		case 'lan':
		case 'nat':
		case 'guest':
			return 'downstream';

		default:
			return 'none';
		}
	}

	function fw_generate_zone(x, n, mode) {
		let u = uci_new_section(x, n, "zone", { name: n, network: n });

		if (mode == "masq") {
			u.input = "REJECT";
			u.output = "ACCEPT";
			u.forward = "REJECT";
			u.masq = 1;
			u.mtu_fix = 1;
		} else if (mode == "guest") {
			u.input = "REJECT";
			u.output = "ACCEPT";
			u.forward = "REJECT";
		} else {
			u.input = "ACCEPT";
			u.output = "ACCEPT";
			u.forward = "ACCEPT";
		}
	}

	function fw_generate_fwd(x, src, dest) {
		let name = sprintf("%s_%s", src, dest);

		uci_new_section(x, name, "forwarding", { src, dest });
	}

	function fw_generate_guest(x, src, ipaddr) {
		let allow = sprintf("%s_allow", src);
		let block = sprintf("%s_block", src);

		uci_new_section(x, allow + "_dns", "rule", {
			name: "Allow-DNS-Guest",
			src,
			dest_port: 53,
			proto: [ "tcp", "udp" ],
			target: "ACCEPT"
		});
		uci_new_section(x, allow + "_dhcp", "rule", {
			name: "Allow-DHCP-Guest",
			src,
			dest_port: 67,
			family: "ipv4",
			proto: "udp",
			target: "ACCEPT"
		});
		uci_new_section(x, block + "_local", "rule", {
			name: "Block-local-Guest",
			src,
			dest: "*",
			family: "ipv4",
			proto: [ "tcp", "udp" ],
			dest_ip: [ "192.168.0.0/16", "172.16.0.0/24", "10.0.0.0/24" ],
			target: "REJECT"
		});
	}

	function fw_generate_ipv6(uci, src_zone, ipv6_role) {
		let prefix = sprintf('%s_allow_', src_zone);

		/* essential IPv6 firewalling in either direction */
		if (ipv6_role != 'none') {
			uci_new_section(uci, prefix + 'mld', 'rule', {
				name: 'Allow MLD requests on ' + src_zone,
				src: src_zone,
				proto: 'icmp',
				src_ip: 'fe80::/10',
				icmp_type: [ '130/0', '131/0', '132/0', '143/0' ],
				family: 'ipv6',
				target: 'ACCEPT'
			});

			uci_new_section(uci, prefix + 'icmpv6_ingress', 'rule', {
				name: 'Allow essential inbound IPv6 ICMP on ' + src_zone,
				src: src_zone,
				proto: 'icmp',
				icmp_type: [
					'echo-request', 'echo-reply', 'destination-unreachable', 'packet-too-big',
					'time-exceeded', 'bad-header', 'unknown-header-type', 'router-solicitation',
					'neighbour-solicitation', 'router-advertisement', 'neighbour-advertisement' ],
				limit: '1000/sec',
				family: 'ipv6',
				target: 'ACCEPT'
			});

			uci_new_section(uci, prefix + 'icmpv6_forward', 'rule', {
				name: 'Allow essential IPv6 ICMP forwarding from ' + src_zone,
				src: src_zone,
				dest: '*',
				proto: 'icmp',
				icmp_type: [
					'echo-request', 'echo-reply', 'destination-unreachable', 'packet-too-big',
					'time-exceeded', 'bad-header', 'unknown-header-type' ],
				limit: '1000/sec',
				family: 'ipv6',
				target: 'ACCEPT'
			});
		}

		/* role specific rules */
		switch (ipv6_role) {
		case 'upstream':
			uci_new_section(uci, prefix + 'dhcpv6', 'rule', {
				name: 'Allow inbound DHCPv6 replies on ' + src_zone,
				src: src_zone,
				proto: 'udp',
				src_ip: 'fc00::/6',
				dest_ip: 'fc00::/6',
				dest_port: '546',
				family: 'ipv6',
				target: 'ACCEPT'
			});

			break;

		case 'downstream':
			uci_new_section(uci, prefix + 'dhcpv6', 'rule', {
				name: 'Allow inbound DHCPv6 requests on ' + src_zone,
				src: src_zone,
				proto: 'udp',
				src_ip: 'fc00::/6',
				dest_ip: 'fc00::/6',
				dest_port: '547',
				family: 'ipv6',
				target: 'ACCEPT'
			});

			break;
		}
	}

	function bridge_generate_vlan(x, n, vid) {
		let name = sprintf("%s_vlan", n);

		uci_new_section(x, name, "bridge-vlan", {
			device: "bridge",
			vlan: vid,
			ports: capab.network.wan.ifname + ":t"
		});
	}

	function dhcp_generate(x, v, n) {
		let u = uci_new_section(x, n, "dhcp", { interface: n });

		if (!v) {
			u.ignore = 1;
			return u;
		}

		uci_defaults(v, { start: 100, limit: 100, leasetime: "12h" });
		uci_set_options(u, v, [ "start", "limit", "leasetime" ]);

		return u;
	}

	function lease_generate(x, v) {
		if (!uci_requires(v, [ "hostname", "mac", "ip" ]))
			return;

		uci_new_section(x, v.hostname, "host", {
			ip: v.ip,
			mac: v.mac,
			hostname: v.hostname
		});
	}

	function network_generate_vlan_rule(x, v, n) {
		if (!v.vlan)
			return;
		let name = sprintf("%s_route", n);

		uci_new_section(x, name, "rule", { "in": n, lookup: v.vlan });
	}

	function network_generate_name(n, v) {
		if (v.name && n in ["guest", "nat", "mesh", "gre", "vxlan"])
			n = v.name;

		return v.vlan ? sprintf("%s%d", n, v.vlan) : n;
	}

	function network_generate_static(x, v, n) {
		let u = uci_new_section(x, n, "interface", { proto: "static" });

		uci_defaults(v, {netmask: "255.255.255.0"});
		uci_set_options(u, v, ["ipaddr", "netmask", "gateway", "dns"]);

		return u;
	}

	function network_generate_dhcp(x, v, n) {
		let u = uci_new_section(x, n, "interface", { proto: "dhcp" });

		return u;
	}

	function network_generate_base(x, v, n) {
		let u;

		switch(v.proto) {
		case "dhcp":
			u = network_generate_dhcp(x.network, v, n);
			break;

		case "static":
			u = network_generate_static(x.network, v, n);
			break;

		default:
			cfg_rejected("network.proto", "", "Unhandled network proto: %s", v.proto);
			return;
		}

		u.metric = 10;
		uci_set_options(u, v, ["mtu", "disabled", "metric"]);

		return u;
	}

	function network_generate_ipv6(uci, base_network, iface_config, iface_section, dhcp_section) {
		let ipv6 = iface_config.cfg.ipv6 || ipv6_default_mode_for_role(iface_config.mode);

		switch (ipv6) {
		case 'upstream':
			let name = network_generate_name(iface_config.mode + '6', iface_config);

			uci_new_section(uci, name, 'interface', {
				ifname: '@' + base_network,
				proto: 'dhcpv6',
				reqprefix: iface_config.cfg.ipv6_reqprefixlen || 'auto'
			});

			if (have_dhcpv6_relay_interfaces()) {
				dhcp_section.ra = 'relay';
				dhcp_section.ndp = 'relay';
				dhcp_section.dhcpv6 = 'relay';
				dhcp_section.master = 1;
			}
			else {
				dhcp_section.ra = 'disabled';
				dhcp_section.ndp = 'disabled';
				dhcp_section.dhcpv6 = 'disabled';
			}

			break;

		case 'downstream':
			iface_section.ip6assign = iface_config.cfg.ipv6_setprefixlen || 60;

			let dhcpv6_mode = iface_config.cfg.ipv6_dhcpmode || 'hybrid';
			let ra_modes = [ 'stateless', 'hybrid', 'stateful' ];

			switch (dhcpv6_mode) {
			case 'stateless':
			case 'hybrid':
			case 'stateful':
				dhcp_section.ra = 'server';
				dhcp_section.ndp = 'disabled';
				dhcp_section.dhcpv6 = 'server';

				/* map mode name to 0/1/2 respectively */
				dhcp_section.ra_management = index(ra_modes, dhcpv6_mode);

				break;

			case 'relay':
				dhcp_section.ra = 'relay';
				dhcp_section.ndp = 'relay';
				dhcp_section.dhcpv6 = 'relay';

				break;
			}

			break;

		case 'none':
			dhcp_section.ra = 'disabled';
			dhcp_section.ndp = 'disabled';
			dhcp_section.dhcpv6 = 'disabled';

			/* ToDo: consider creating a config device section with
			 * `option ipv6 0` to also disable IPv6-LL */

			break;
		}

		fw_generate_ipv6(uci.firewall, base_network, ipv6);
	}

	function network_generate_wan(x, v) {
		let name = network_generate_name("wan", v);
		let u;

		u = network_generate_base(x, v.cfg, name);
		u.metric = 1;

		if (v.vlan) {
			if (capab["bridge-vlan"] === true)
				u.ifname = sprintf("bridge.%d", v.vlan);
			else
				u.ifname = sprintf("@wan.%d", v.vlan);

			u.ip4table = v.vlan;
			u.ip6table = v.vlan;
			u.type = nil;

			if (capab["bridge-vlan"])
				bridge_generate_vlan(x.network, name, v.vlan);

			fw_generate_zone(x.firewall, name, "masq");
		} else if (v.cfg.repeater) {
			u.type = nil;
			u.ifname = nil;
		} else if (!capab["bridge-vlan"]) {
			u.type = "bridge";
			u.ifname = capab.network.wan.ifname;
		}

		let dhcp = dhcp_generate(x.dhcp, false, name);

		network_generate_ipv6(x, name, v, u, dhcp);
	}

	function network_generate_lan(x, c, n) {
		let name = network_generate_name(n, c);
		let ipv6 = ipv6_default_mode_for_role(n);
		let u, dhcp;

		u = network_generate_base(x, c.cfg, name);
		dhcp = dhcp_generate(x.dhcp, c.cfg.dhcp, name);

		for (let k, v in c.cfg.leases)
			lease_generate(x.dhcp, v);

		network_generate_vlan_rule(x.network, c, name);

		network_generate_ipv6(x, name, c, u, dhcp);

		return u;
	}

	function network_generate_nat(x, c, n) {
		let name = network_generate_name(n, c);
		let wan = network_generate_name("wan", c);
		let u;

		u = network_generate_lan(x, c, n);
		u.type = "bridge";

		fw_generate_zone(x.firewall, name, n);
		fw_generate_fwd(x.firewall, name, wan);
	}

	function network_generate_guest(x, c) {
		let name = network_generate_name("guest", c);

		network_generate_nat(x, c, "guest");
		fw_generate_guest(x.firewall, name, c.cfg.ipaddr);
	}

	function network_generate_batman(x, v) {
		let u = uci_new_section(x.network, "bat0", "interface", { proto: "batadv" });

		uci_defaults(v, { multicast_mode: 0, distributed_arp_table: 0, orig_interval: 5000 });
		uci_set_options(u, v, [ "multicast_mode", "distributed_arp_table", "orig_interval" ]);

		if (capab["bridge-vlan"] === true)
			uci_new_section(x.network, "wan_vlan", "bridge-vlan", {
				ports: [ capab.network.wan.ifname, "bat0" ]
			});
		else
			uci_new_section(x.network, "wan", "interface", {
				ifname: [ capab.network.wan.ifname, "bat0" ]
			});
	}

	function network_generate_mesh(x, v) {
		let name = network_generate_name("mesh", v);
		let u;

		u = uci_new_section(x.network, name, "interface", {
			proto: "batadv_hardif",
			master: "bat0"
		});

		uci_defaults(v, { mtu: 1532 });
		uci_set_options(u, v, [ "mtu" ]);
	}

	function network_generate_gre(x, v) {
		if (!uci_requires(v.cfg, [ "peeraddr" ])) {
			cfg_rejected("network.gre", "", "missing gre options");
			return;
		}

		uci_defaults(v.cfg, {tunlink: "wan" });

		let name = network_generate_name("gre", v);
		let tun_name = sprintf("%stun", name);
		let ifname = sprintf("gre4t-%s", name);

		if (v.cfg.vid) {
			tun_name = sprintf("%s_%d", tun_name, v.cfg.vid);
			ifname = sprintf("%s.%d", ifname, v.cfg.vid);
		}

		let u = uci_new_section(x.network, name, "interface", {
			proto: "gretap",
			type: "gre"
		});

		uci_set_options(u, v.cfg, [ "ipaddr", "peeraddr", "tunlink" ]);

		uci_new_section(x.network, tun_name, "interface", {
			proto: "static",
			type: "bridge",
			ifname: ifname
		});
	}

	function network_generate_vxlan(x, v) {
		if (!uci_requires(v.cfg, [ "peeraddr", "ipaddr", "netmask" ])) {
			cfg_rejected("network.vxlan", "", "missing vxlan options");
			return;
		}

		uci_defaults(v.cfg, {tunlink: "wan", port: 4789, "vid": 1});

		let name = network_generate_name("vxlan", v);
		let tun_name = sprintf("%speer", name);
		let ifname = sprintf("@%s", name);

		let u = uci_new_section(x.network, name, "interface", {
			proto: "vxlan",
		});

		uci_set_options(u, v.cfg, [ "peeraddr", "tunlink", "port", "vid" ]);

		u = uci_new_section(x.network, tun_name, "interface", {
			type: "bridge",
			proto: "static",
			ifname: ifname,
		});

		uci_set_options(u, v.cfg, [ "ipaddr", "netmask" ]);

		if (v.cfg.tunlink == "wan")
			uci_new_section(x.firewall, sprintf("%s_accept", name), "rule", {
				src: "wan",
				proto: "udp",
				port: v.cfg.port,
				target: "ACCEPT"
			});
	}

	function network_generate() {
		let uci = {
			network: {},
			dhcp: {},
			firewall: {}
		};

		for (let k, v in cfg.network) {
			switch (v.mode) {
			case "wan":
				network_generate_wan(uci, v);
				break;

			case "nat":
				network_generate_nat(uci, v, "nat");
				break;

			case "lan":
				network_generate_lan(uci, v, "lan");
				break;

			case "guest":
				network_generate_guest(uci, v);
				break;

			case "batman":
				network_generate_batman(uci, v);
				break;

			case "mesh":
				network_generate_mesh(uci, v);
				break;

			case "gre":
				network_generate_gre(uci, v);
				break;

			case "vxlan":
				network_generate_vxlan(uci, v);
				break;

			default:
				cfg_rejected("network", "","trying to create network with unknown mode %s", v.mode);
				break;
			}
		}

		uci_render("network", uci.network);
		uci_render("dhcp", uci.dhcp);
		uci_render("firewall", uci.firewall);
	}

	network_generate();
%}

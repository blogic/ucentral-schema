{%
function fw_generate_zone(x, n, masq) {
	local u = uci_new_section(x, n, "zone", {"name": n, "network": n});

	if (masq) {
		u.input = "REJECT";
		u.output = "ACCEPT";
		u.forward = "REJECT";
		u.masq = 1;
		u.mtu_fix = 1;
	} else {
		u.input = "ACCEPT";
		u.output = "ACCEPT";
		u.forward = "ACCEPT";
	}
}

function fw_generate_fwd(x, src, dest) {
	local name = sprintf("%s_%s", src, dest);

	uci_new_section(x, name, "forwarding", {"src": src, "dest": dest});
}

function fw_generate_guest(x, src, ipaddr) {
	local allow = sprintf("%s_allow", src);
	local block = sprintf("%s_block", src);

	if (ipaddr)
		uci_new_section(x, allow, "rule", {"src": src, "family": "ipv4",
					  "dest_ip": ipaddr, "dest": "*",
					  "proto": "tcp udp", "target": "ACCEPT" });

	uci_new_section(x, block, "rule", {"src": src, "family": "ipv4", "dest": "*",
					  "dest_ip": "192.168.0.0/16 172.16.0.0/24 10.0.0.0/24",
					  "proto": "tcp udp", "target": "REJECT" });
}

function bridge_generate_vlan(x, n, vid) {
	local name = sprintf("%s_vlan", n);

	uci_new_section(x, name, "bridge-vlan", {"device": "bridge", "vlan": vid,
						 "ports": capab.network.wan.ifname + ":t"});
}

function dhcp_generate(x, v, n) {
	local u = uci_new_section(x, n, "dhcp", {"interface": n});

	if (!v) {
		u.ignore = 1;
		return;
	}
	uci_defaults(v, { "start": 100, "limit": 100, "leasetime": "12h" });
	uci_set_options(u, v, ["start", "limit", "leasetime"]);
}

function lease_generate(x, v) {
	if (!uci_requires(v, [ "hostname", "mac", "ip" ]))
		return;

	uci_new_section(x, v.hostname, "host", {
		"hostname": v.hostname, 
		"ip": v.ip, 
		"mac":v.mac  
	});
}

function network_generate_vlan_rule(x, v, n) {
	if (!v.vlan)
		return;
	local name = sprintf("%s_route", n);

	uci_new_section(x, name, "rule", {"in": n, "lookup": v.vlan});
}

function network_generate_name(n, v) {
	if (v.name && n in ["guest", "nat", "mesh", "gre"])
		n = v.name;
	return v.vlan ? sprintf("%s%d", n, v.vlan) : n;
}

function network_generate_static(x, v, n) {
	local u = uci_new_section(x, n, "interface", {"proto": "static"});

	uci_defaults(v, {"netmask": "255.255.255.0"});
	uci_set_options(u, v, ["ipaddr", "netmask", "gateway", "dns"]);

	return u;
}

function network_generate_dhcp(x, v, n) {
	local u = uci_new_section(x, n, "interface", {"proto": "dhcp"});

	return u;
}

function network_generate_base(x, v, n) {
	local u;

	switch(v.proto) {
	case "dhcp":
		u = network_generate_dhcp(x.network, v, n);
		break;
	case "static":
		u = network_generate_static(x.network, v, n);
		break;
	default:
		cfg_error(sprintf("Unhandled network proto: %s", v.proto));
		return;
	}

	uci_set_options(u, v, ["mtu", "ip6assign", "disabled"]);

	return u;
}

function network_generate_wan(x, v) {
	local name = network_generate_name("wan", v);
	local u;

	u = network_generate_base(x, v.cfg, name);
	if (v.vlan) {
		if (capab["bridge-vlan"] === true)
			u.ifname = sprintf("bridge.%d", v.vlan);
		else
			u.ifname = sprintf("@wan.%d", v.vlan);
		u.ip4table = v.vlan;
		u.ip6table = v.vlan;
		if (capab["bridge-vlan"])
			bridge_generate_vlan(x.network, name, v.vlan);
		fw_generate_zone(x.firewall, name, true);
	} else if (!capab["bridge-vlan"])
		u.type = "bridge";
	dhcp_generate(x.dhcp, false, name);
}

function network_generate_lan(x, c, n) {
	local name = network_generate_name(n, c);
	local u;

	u = network_generate_base(x, c.cfg, name);
	dhcp_generate(x.dhcp, c.cfg.dhcp, name);
	for (local k, v in c.cfg.leases)
		lease_generate(x.dhcp, v);
	network_generate_vlan_rule(x.network, c, name);
	return u;
}

function network_generate_nat(x, c, n) {
	local name = network_generate_name(n, c);
	local wan = network_generate_name("wan", c);
	local u;

	u = network_generate_lan(x, c, n);
	u.type = "bridge";

	fw_generate_zone(x.firewall, name);
	fw_generate_fwd(x.firewall, name, wan);
}

function network_generate_guest(x, c) {
	local name = network_generate_name("guest", c);

	network_generate_nat(x, c, "guest");
	fw_generate_guest(x.firewall, name, c.cfg.ipaddr);
}

function network_generate_batman(x, v) {
	local u = uci_new_section(x.network, "bat0", "interface", {"proto": "batadv"});

	uci_defaults(v, {"multicast_mode": 0, "distributed_arp_table": 0, "orig_interval": 5000});
	uci_set_options(u, v, ["multicast_mode", "distributed_arp_table", "orig_interval"]);
	if (capab["bridge-vlan"] === true)
		uci_new_section(x.network, "wan_vlan", "bridge-vlan",
			{"ports": capab.network.wan.ifname + " " + "bat0"});
	else
		uci_new_section(x.network, "wan", "interface",
			{"ifname": capab.network.wan.ifname + " " + "bat0"});

}

function network_generate_mesh(x, v) {
	local name = network_generate_name("mesh", v);
	local u;

	u = uci_new_section(x.network, name, "interface", {"proto": "batadv_hardif", "master": "bat0"});
	uci_defaults(v, {"mtu": 1532});
	uci_set_options(u, v, ["mtu"]);
}

function network_generate_gre(x, v) {
	if (!uci_requires(v.cfg, [ "peeraddr" ])) {
		cfg_error("missing gre options");
		return;
	}
	uci_defaults(v.cfg, {"tunlink": "wan" });

	local name = network_generate_name("gre", v);
	local tun_name = sprintf("%stun", name);
	local ifname = sprintf("gre4t-%s", name);
	if (v.cfg.vid) {
		tun_name = sprintf("%s_%d", tun_name, v.cfg.vid);
		ifname = sprintf("%s.%d", ifname, v.cfg.vid);
	}
	local u = uci_new_section(x.network, name, "interface", {"proto": "gretap", "type": "gre"});
	uci_set_options(u, v.cfg, ["ipaddr", "peeraddr", "tunlink"]);

	uci_new_section(x.network, tun_name, "interface", {"proto": "static", "type": "bridge",
						    "ifname": ifname});
}

function network_generate() {
	local uci = {
		"network": {},
		"dhcp": {},
		"firewall": {}
	};

        for (local k, v in cfg.network) {
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
		default:
			cfg_error(sprintf("trying to create network with unknown mode %s", v.mode));
			break;
		}
	}
	uci_render("network", uci.network);
	uci_render("dhcp", uci.dhcp);
	uci_render("firewall", uci.firewall);
}

network_generate();
%}

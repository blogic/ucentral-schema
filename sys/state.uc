{%
	/* set up basic functionality */
	if (!cursor)
		cursor = uci.cursor();
	if (!ctx)
		ctx = ubus.connect();

	let state = {
		unit: { memory: {} },
		radios: [],
		interfaces: []
	};

	/* find out what telemetry we should gather */
	let stats;
	if (!length(stats)) {
		cursor.load("ustats");
		stats = cursor.get_all("ustats", "stats");
	}

	/* load state data */
	let ipv6leases = ctx.call("dhcp", "ipv6leases");
	let topology = ctx.call("topology", "mac");
	let wifistatus = ctx.call("network.wireless", "status");
	let wifiiface = ctx.call("wifi", "iface");
	let stations = ctx.call("wifi", "station");
	let ports = ctx.call("topology", "port");
	let lldp = {};

	/* prepare dhcp leases cache */
	let ip4leases = {};
	try {
		let fd = fs.open("/tmp/dhcp.leases");
		if (fd) {
			let line;
			while (line = fd.read("line")) {
				let tokens = split(line, " ");

				if (length(tokens) < 4)
					continue;

				ip4leases[tokens[1]] = {
					assigned: tokens[0],
					mac: tokens[1],
					address: tokens[2],
					hostname: tokens[3]
				};
			}
			fd.close();
		}
	}
	catch(e) {
		log("Failed to parse dhcp leases cache: %s\n%s\n", e, e.stacktrace[0].context);
	}

	/* prepare lldp cache */
	try {
		let stdout = fs.popen("lldpcli -f json show neighbors");
		let tmp;
		if (stdout) {
			tmp = json(stdout.read("all")).lldp;
			stdout.close();
		} else {
			log("LLDP cli command failed: %s", fs.error());
		}

		for (let key, iface in tmp) {
			for (let port, info in iface) {
				let peer = { };

				for (let host, chassis in info.chassis) {
					if (!length(chassis.id) ||
					    !length(chassis.descr))
						continue;
					peer.mac = chassis.id.value;
					peer.port = port;
					peer.description = chassis.descr;

					if (length(chassis.mgmt_ip))
						peer.management_ips = chassis["mgmt-ip"];

					if (length(chassis.capability)) {
						let cap = [];

						for (let c in chassis.capability) {
							if (!c.enabled)
								continue;
							push(cap, c.type);
						}
						peer.capability = cap;
					}

				}

				if (!length(peer) ||
				    !length(info.port) ||
				    !length(info.port.id) ||
				    !info.port.id.value)
					continue;

				lldp[info.port.id.value] = peer;
			}
		}
	}
	catch(e) {
		log("Failed to parse LLDP cli output: %s\n%s\n", e, e.stacktrace[0].context);
	}

	/* system state */
	let system = ctx.call("system", "info");
	state.unit.localtime = system.localtime;
	state.unit.uptime = system.uptime;
	state.unit.load = system.load;
	state.unit.memory.total = system.memory.total;
	state.unit.memory.free = system.memory.free;

	/* wifi radios */
	for (let radio, data in wifistatus) {
		if (!length(data.interfaces))
			continue;
		let vap = wifiiface[data.interfaces[0].ifname];
		if (!length(vap))
			continue;

		let radio = {};
		radio.frequencies = vap.frequency;
		radio.channel_width = vap.ch_width;
		radio.tx_power = vap.tx_power;
		push(state.radios, radio);
	}

	/* interfaces */
	cursor.load("network");
	cursor.foreach("network", "interface", function(d) {
		let name = d[".name"];
		if (name == "loopback")
			return;

		let iface = {name};
		let ipv4leases = [];
		let lldp_neigh = [];

		push(state.interfaces, iface);

		let status = ctx.call(sprintf("network.interface.%s", name) , "status");

		if (!length(status))
			return;

		iface.uptime = status.uptime;

		if (length(status["ipv4-address"])) {
			let ipv4 = [];

			for (let a in status["ipv4-address"])
				push(ipv4, sprintf("%s/%d", a.address, a.mask));

			iface.ipv4_addresses = ipv4;
		}

		if (length(status["ipv6-address"])) {
			iface.ipv6_addresses = status["ipv6-address"];
			for (let key, addr in iface.ipv6_addresses) {
				printf("%s %s\n", key, addr);
				if (!addr.mask)
					continue;
				addr.address = sprintf("%s/%s", addr.address, addr.mask);
				delete(addr, "mask");
			}
		}

		if (length(status["dns-server"]))
			iface.dns_servers = status["dns-server"];

		if (length(status.data) && status.data.ntpserver)
			iface.ntp_server = status.data.ntpserver;

		if (length(status.data) && status.data.leasetime && status.proto == "dhcp")
			iface.ipv4_leasetime = status.data.leasetime;

		if (length(ipv6leases) &&
		    length(ipv6leases.device) &&
		    length(ipv6leases.device[status.device]) &&
		    length(ipv6leases.device[status.device].leases)) {
			let leases = [];

			for (let l in ipv6leases.device[status.device].leases) {
				let lease = {};

				lease.hostname = l.hostname;
				lease.addresses = [];
				for (let addr in l["ipv6-addr"])
					push(lease.addresses, addr.address);
				push(leases, lease);
			}

			if (length(leases))
				iface.ipv6_leases = leases
		}

		if (length(topology)) {
			let clients = [];

			for (let mac, topo in topology) {
				if (topo.interface != d[".name"] ||
				    !length(topo.fdb) ||
				    (!length(topo["ipv4"]) && !length(topo["ipv6"])))
					continue;

				let client = {};

				if (length(ip4leases[mac]))
					push(ipv4leases, ip4leases[mac]);

				if (length(lldp[mac]))
					push(lldp_neigh, lldp[mac]);

				client.mac = mac;
				if (length(topo["ipv4"]))
					client.ipv4_addresses = topo["ipv4"];
				if (length(topo["ipv6"]))
					client.ipv6_addresses = topo["ipv6"];
				client.ports = topo.fdb;
				client.last_seen == topo.last_seen;
				if (stats.clients)
					push(clients, client);
			}

			if (length(ipv4leases))
				iface.ipv4_leases = ipv4leases;

			if (stats.lldp && length(lldp_neigh))
				iface.lldp_neighbours = lldp_neigh;

			if (length(clients))
				iface.clients = clients;
		}

		if (stats.clients && stats.lldp) {
			try {
				for (let netdev, l in lldp.interface) {
				}
			} catch(e) {
				print(e);
			};
		}

		if (stats.ssids && length(wifistatus)) {
			let ssids = [];
			let counter = 0;

			for (let radio, data in wifistatus) {
				for (let k, vap in data.interfaces) {
					if (!length(vap.config) ||
					    !length(vap.config.network) ||
					    !(name in vap.config.network) ||
					    !wifiiface[vap.ifname])
						continue;
					let iface = wifiiface[vap.ifname];
					let ssid = {
						radio:{"$ref": sprintf("#/radios/%d", counter)}
					};

					ssid.ssid = iface.ssid;
					ssid.mode = iface.mode;
					ssid.bssid = iface.mac;

					if (length(stations[vap.ifname]))
						ssid.associations = stations[vap.ifname];

					push(ssids, ssid);
				}
				counter++;
			}
			if (length(ssids))
				iface.ssids = ssids;
		}

		if (length(ports[name]) && length(ports[name].stats)) {
			iface.counters = ports[name].stats;
			for (let key in iface.counters)
				if (!iface.counters[key])
					delete(iface.counters, key);
		}
	});

	printf("%s\n", state);

	let msg = {
		uuid: cfg.uuid,
		serial: cursor.get("ucentral", "config", "serial"),
		state
	};
	ctx.call("ucentral", "stats", msg);
%}

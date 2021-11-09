#!/usr/bin/ucode
{%
	let fs = require("fs");

	/* if we are actively streaming telemetry then the state handler does not need to run
	   independently */
	if (!telemetry && fs.stat("/tmp/ucentral.telemetry"))
		return 0;

	let uci = require("uci");
	let ubus = require("ubus");
	let cfgfile = fs.open("/etc/ucentral/ucentral.active", "r");
	let cfg = json(cfgfile.read("all"));
	let capabfile = fs.open("/etc/ucentral/capabilities.json", "r");
	let capab = json(capabfile.read("all"));

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
	let wifiphy = ctx.call("wifi", "phy");
	let wifiiface = ctx.call("wifi", "iface");
	let stations = ctx.call("wifi", "station");
	let ports = ctx.call("topology", "port");
	let poe = ctx.call("poe", "info");
	let gps = ctx.call("gps", "info");
	let lldp = [];

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
		printf("Failed to parse dhcp leases cache: %s\n%s\n", e, e.stacktrace[0].context);
	}

	/* prepare lldp cache */
	try {
		let stdout = fs.popen("lldpcli -f json show neighbors");
		let tmp;
		if (stdout) {
			tmp = json(stdout.read("all")).lldp[0].interface;
			stdout.close();
		} else {
			printf("LLDP cli command failed: %s", fs.error());
		}

		for (let key, iface in tmp) {
			let peer = { };
			for (let host, chassis in iface.chassis) {
				if (!length(chassis.id) ||
				    !length(chassis.descr))
					continue;
				peer.mac = chassis.id[0].value;
				peer.port = iface.name;
				peer.description = chassis.descr[0].value;

				if (length(chassis.name))
					peer.name = chassis.name[0].value;

				if (length(chassis.mgmt_ip)) {
					let ipaddr = [];

					for (let ip in chassis["mgmt-ip"])
						push(ipaddr, ip.value);
					peer.ips = ips;
				}

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

			if (!length(peer))
				continue;

			push(lldp, peer);
		}
	}
	catch(e) {
		printf("Failed to parse LLDP cli output: %s\n%s\n", e, e.stacktrace[0].context);
	}

	/* system state */
	let system = ctx.call("system", "info");
	state.unit.localtime = system.localtime;
	state.unit.uptime = system.uptime;
	state.unit.load = system.load;
	state.unit.memory.total = system.memory.total;
	state.unit.memory.free = system.memory.free;
	state.unit.memory.cached = system.memory.cached;
	state.unit.memory.buffered = system.memory.buffered;

	for (let l = 0; l < 3; l++)
		state.unit.load[l] /= 65535.0;

	/* wifi radios */
	for (let radio, data in wifistatus) {
		if (!length(data.interfaces))
			continue;
		let vap = wifiiface[data.interfaces[0].ifname];
		if (!length(vap))
			continue;

		let radio = {};
		radio.channel = vap.channel;
		radio.channel_width = vap.ch_width;
		radio.tx_power = vap.tx_power;
		let survey = ctx.call('wifi', 'survey', { 'channel': radio.channel[0] });
		for (let k, v in survey)
			radio[k] = v;
		delete radio.in_use;
		radio.phy = data.config.path;
		if (wifiphy[data.config.path] && wifiphy[data.config.path].temperature)
			radio.temperature = wifiphy[data.config.path].temperature;
		push(state.radios, radio);
	}
	if (!length(state.radios))
		delete state.radios;

	/* interfaces */
	cursor.load("network");
	cursor.foreach("network", "interface", function(d) {
		let name = d[".name"];
		if (name == "loopback")
			return;
		if (index(name, "_") >= 0)
			return;
		if (!d.ucentral_path)
			return;

		let iface = { name, location: d.ucentral_path, ipv4:{}, ipv6:{} };
		let ipv4leases = [];

		push(state.interfaces, iface);

		let status = ctx.call(sprintf("network.interface.%s", name) , "status");

		if (!length(status))
			return;

		let device = ctx.call("network.device", "status", { name });

		if (device && length(device["bridge-members"]))
		iface.ports = device["bridge-members"];
		iface.uptime = status.uptime || 0;

		if (length(status["ipv4-address"])) {
			let ipv4 = [];

			for (let a in status["ipv4-address"])
				push(ipv4, sprintf("%s/%d", a.address, a.mask));

			iface.ipv4.addresses = ipv4;
		}

		if (length(status["ipv6-address"])) {
			iface.ipv6.addresses = status["ipv6-address"];
			for (let key, addr in iface.ipv6.addresses) {
				if (!addr.mask)
					continue;
				addr.address = sprintf("%s/%s", addr.address, addr.mask);
				delete addr.mask;
			}
		}

		if (length(status["dns-server"]))
			iface.dns_servers = status["dns-server"];

		if (length(status.data) && status.data.ntpserver)
			iface.ntp_server = status.data.ntpserver;

		if (length(status.data) && status.data.leasetime && status.proto == "dhcp")
			iface.ipv4.leasetime = status.data.leasetime;

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
				iface.ipv6.leases = leases
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

				client.mac = mac;
				if (length(topo["ipv4"]))
					client.ipv4_addresses = topo["ipv4"];
				if (length(topo["ipv6"]))
					client.ipv6_addresses = topo["ipv6"];
				client.ports = topo.fdb;
				client.last_seen == topo.last_seen;
				if (index(stats.types, 'clients') >= 0)
					push(clients, client);
			}

			if (length(ipv4leases))
				iface.ipv4.leases = ipv4leases;


			if (length(clients))
				iface.clients = clients;
		}

		if (index(stats.types, 'lldp') >= 0) {
			let lldp_neigh = [];

			for (let port in iface.ports)
				for (let l in lldp)
					if (l.port == port)
						push(lldp_neigh, l);
			if (length(lldp_neigh))
				iface.lldp = lldp_neigh;
		}

		if (index(stats.types, 'ssids') >= 0 && length(wifistatus)) {
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
						radio:{"$ref": sprintf("#/radios/%d", counter)},
						phy: data.config.path
					};

					ssid.ssid = iface.ssid;
					ssid.mode = iface.mode;
					ssid.bssid = iface.bssid;

					if (length(stations[vap.ifname]))
						ssid.associations = stations[vap.ifname];


					ssid.iface = vap.ifname;
					ssid.counters = ports[vap.ifname].stats;
					if (!ssid.counters)
						delete ssid.counters;

					push(ssids, ssid);
				}
				counter++;
			}
			if (length(ssids))
				iface.ssids = ssids;
		}

		if (length(ports) && length(ports[name]) && length(ports[name].stats)) {
			iface.counters = ports[name].stats;
			for (let key in iface.counters)
				if (!iface.counters[key])
					delete iface.counters.key;
		}
		if (!length(iface.ipv4))
			delete iface.ipv4;
		if (!length(iface.ipv6))
			delete iface.ipv6;
	});

	if (length(poe)) {
		state.poe = {};
		state.poe.consumption = poe.consumption;
		state.poe.ports = [];
		for (let k, v in poe.ports) {
			let port = {
				id: replace(k, 'lan', ''),
				status: v.status
			};
			if (v.consumption)
				port.consumption = v.consumption;
			push(state.poe.ports, port);
		}
	}

	if (length(gps) && gps.latitude)
		state.gps = {
			latitude: gps.latitude,
			longitude: gps.longitude,
			elevation: gps.elevation
		};

	function sysfs_net(iface, prop) {
		let f = fs.open(sprintf("/sys/class/net/%s/%s", iface, prop), "r");
		let val = false;

		if (f) {
			val = replace(f.read("all"), '\n', '');
			f.close();
		}

		return val;
	}

	if (length(capab.network)) {
		let link = {};

		for (let name, net in capab.network) {
			link[name] = {};

			for (let iface in capab.network[name]) {
				let state = {};

				state.carrier = +sysfs_net(iface, "carrier");
				if (state.carrier) {
					state.speed = +sysfs_net(iface, "speed");
					state.duplex = sysfs_net(iface, "duplex");
				}
				link[name][iface] = state;
			}
		}
		state["link-state"] = link;
	}

	printf("%s\n", state);

	let msg = {
		uuid: cfg.uuid || 1,
		serial: cursor.get("ucentral", "config", "serial"),
		state
	};
	ctx.call("ucentral", "stats", msg);

	if (telemetry)
		ctx.call("ucentral", "event", { "event": "state", "payload": msg });

	let f = fs.open("/tmp/ucentral.state", "w");
	if (f) {
		f.write(msg);
		f.close();
	}
	else {
		printf("Unable to open %s for writing: %s", statefile_path, fs.error());
	}
%}

{%
// Automatically generated from ./ucentral.schema.pretty.json - do not edit!
"use strict";

function instantiateUnit(value) {
	assert(type(value) == "object", "Property unit must be of type object");

	let obj = {};

	if (exists(value, "name")) {
		assert(type(value["name"]) == "string", "Property unit.name must be of type string");
		obj.name = value["name"];
	}

	if (exists(value, "location")) {
		assert(type(value["location"]) == "string", "Property unit.location must be of type string");
		obj.location = value["location"];
	}

	if (exists(value, "timezone")) {
		assert(type(value["timezone"]) == "string", "Property unit.timezone must be of type string");
		obj.timezone = value["timezone"];
	}

	return obj;
}

function instantiateGlobals(value) {
	assert(type(value) == "object", "Property globals must be of type object");

	let obj = {};

	if (exists(value, "ipv4-network")) {
		assert(type(value["ipv4-network"]) == "string", "Property globals.ipv4-network must be of type string");
		obj.ipv4_network = value["ipv4-network"];
	}

	if (exists(value, "ipv6-network")) {
		assert(type(value["ipv6-network"]) == "string", "Property globals.ipv6-network must be of type string");
		obj.ipv6_network = value["ipv6-network"];
	}

	return obj;
}

function instantiateDefinitions(value) {
	assert(type(value) == "object", "Property definitions must be of type object");

	let obj = {};

	function parseWirelessEncryption(value) {
		assert(type(value) == "object", "Property definitions.wireless-encryption must be of type object");

		let obj = {};

		return obj;
	}

	if (exists(value, "wireless-encryption")) {
		obj.wireless_encryption = parseWirelessEncryption(value["wireless-encryption"]);
	}

	return obj;
}

function instantiateRadioHe(value) {
	assert(type(value) == "object", "Property radio.he must be of type object");

	let obj = {};

	if (exists(value, "multiple-bssid")) {
		assert(type(value["multiple-bssid"]) == "bool", "Property radio.he.multiple-bssid must be of type boolean");
		obj.multiple_bssid = value["multiple-bssid"];
	}
	else {
		obj.multiple_bssid = false;
	}

	if (exists(value, "ema")) {
		assert(type(value["ema"]) == "bool", "Property radio.he.ema must be of type boolean");
		obj.ema = value["ema"];
	}
	else {
		obj.ema = false;
	}

	if (exists(value, "bss-color")) {
		assert(type(value["bss-color"]) == "int", "Property radio.he.bss-color must be of type integer");
		obj.bss_color = value["bss-color"];
	}
	else {
		obj.bss_color = 64;
	}

	return obj;
}

function instantiateRadio(value) {
	assert(type(value) == "object", "Property radio must be of type object");

	let obj = {};

	if (exists(value, "band")) {
		assert(type(value["band"]) == "string", "Property radio.band must be of type string");
		assert(value["band"] in [ "2G", "5G", "6G" ], "Property radio.band must be one of [ \"2G\", \"5G\", \"6G\" ]");
		obj.band = value["band"];
	}

	if (exists(value, "bandwidth")) {
		assert(type(value["bandwidth"]) == "int", "Property radio.bandwidth must be of type integer");
		assert(value["bandwidth"] in [ 5, 10, 20 ], "Property radio.bandwidth must be one of [ 5, 10, 20 ]");
		obj.bandwidth = value["bandwidth"];
	}

	function parseChannel(value) {
		function parseVariant0(value) {
			assert(type(value) == "int", "Property radio.channel must be of type integer");
			assert(value <= 171, "Property radio.channel must be <= 171");
			assert(value >= 1, "Property radio.channel must be >= 1");

			return value;
		}

		function parseVariant1(value) {
			assert(type(value) == "string", "Property radio.channel must be of type string");
			assert(value in [ "auto" ], "Property radio.channel must be one of [ \"auto\" ]");

			return value;
		}

		let success = 0, errors = [];

		try { parseVariant0(value); success++; }
		catch (e) { push(errors, e); }

		try { parseVariant1(value); success++; }
		catch (e) { push(errors, e); }

		assert(success == 1, join("\n- or -\n", errors));

		return value;
	}

	if (exists(value, "channel")) {
		obj.channel = parseChannel(value["channel"]);
	}

	if (exists(value, "country")) {
		assert(type(value["country"]) == "string", "Property radio.country must be of type string");
		assert(length(value["country"]) <= 2, "Property radio.country must be <= 2 characters long");

		assert(length(value["country"]) >= 2, "Property radio.country must be >= 2 characters long");

		obj.country = value["country"];
	}

	if (exists(value, "channel-mode")) {
		assert(type(value["channel-mode"]) == "string", "Property radio.channel-mode must be of type string");
		assert(value["channel-mode"] in [ "HT", "VHT", "HE" ], "Property radio.channel-mode must be one of [ \"HT\", \"VHT\", \"HE\" ]");
		obj.channel_mode = value["channel-mode"];
	}

	if (exists(value, "channel-width")) {
		assert(type(value["channel-width"]) == "int", "Property radio.channel-width must be of type integer");
		assert(value["channel-width"] in [ 20, 40, 80, 160, 8080 ], "Property radio.channel-width must be one of [ 20, 40, 80, 160, 8080 ]");
		obj.channel_width = value["channel-width"];
	}

	if (exists(value, "require-mode")) {
		assert(type(value["require-mode"]) == "string", "Property radio.require-mode must be of type string");
		assert(value["require-mode"] in [ "HT", "VHT", "HE" ], "Property radio.require-mode must be one of [ \"HT\", \"VHT\", \"HE\" ]");
		obj.require_mode = value["require-mode"];
	}

	if (exists(value, "mimo")) {
		assert(type(value["mimo"]) == "string", "Property radio.mimo must be of type string");
		assert(value["mimo"] in [ "1x1", "2x2", "3x3", "4x4", "5x5", "6x6", "7x7", "8x8" ], "Property radio.mimo must be one of [ \"1x1\", \"2x2\", \"3x3\", \"4x4\", \"5x5\", \"6x6\", \"7x7\", \"8x8\" ]");
		obj.mimo = value["mimo"];
	}

	if (exists(value, "tx-power")) {
		assert(type(value["tx-power"]) == "int", "Property radio.tx-power must be of type integer");
		assert(value["tx-power"] <= 30, "Property radio.tx-power must be <= 30");
		assert(value["tx-power"] >= 0, "Property radio.tx-power must be >= 0");
		obj.tx_power = value["tx-power"];
	}

	if (exists(value, "legacy-rates")) {
		assert(type(value["legacy-rates"]) == "bool", "Property radio.legacy-rates must be of type boolean");
		obj.legacy_rates = value["legacy-rates"];
	}
	else {
		obj.legacy_rates = false;
	}

	if (exists(value, "beacon-interval")) {
		assert(type(value["beacon-interval"]) == "int", "Property radio.beacon-interval must be of type integer");
		assert(value["beacon-interval"] <= 65535, "Property radio.beacon-interval must be <= 65535");
		assert(value["beacon-interval"] >= 15, "Property radio.beacon-interval must be >= 15");
		obj.beacon_interval = value["beacon-interval"];
	}
	else {
		obj.beacon_interval = 100;
	}

	if (exists(value, "dtim-period")) {
		assert(type(value["dtim-period"]) == "int", "Property radio.dtim-period must be of type integer");
		assert(value["dtim-period"] <= 255, "Property radio.dtim-period must be <= 255");
		assert(value["dtim-period"] >= 1, "Property radio.dtim-period must be >= 1");
		obj.dtim_period = value["dtim-period"];
	}
	else {
		obj.dtim_period = 2;
	}

	if (exists(value, "he-settings")) {
		obj.he_settings = instantiateRadioHe(value["he-settings"]);
	}

	function parseHostapdIfaceRaw(value) {
		assert(type(value) == "array", "Property radio.hostapd-iface-raw must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of radio.hostapd-iface-raw must be of type string");
			return item;
		});
	}

	if (exists(value, "hostapd-iface-raw")) {
		obj.hostapd_iface_raw = parseHostapdIfaceRaw(value["hostapd-iface-raw"]);
	}

	return obj;
}

function instantiateInterfaceVlan(value) {
	assert(type(value) == "object", "Property interface.vlan must be of type object");

	let obj = {};

	if (exists(value, "id")) {
		assert(type(value["id"]) == "int", "Property interface.vlan.id must be of type integer");
		assert(value["id"] <= 4096, "Property interface.vlan.id must be <= 4096");
		assert(value["id"] >= 2, "Property interface.vlan.id must be >= 2");
		obj.id = value["id"];
	}

	if (exists(value, "proto")) {
		assert(type(value["proto"]) == "string", "Property interface.vlan.proto must be of type string");
		assert(value["proto"] in [ "802.1ad", "802.1q" ], "Property interface.vlan.proto must be one of [ \"802.1ad\", \"802.1q\" ]");
		obj.proto = value["proto"];
	}
	else {
		obj.proto = "802.1q";
	}

	return obj;
}

function instantiateInterfaceBridge(value) {
	assert(type(value) == "object", "Property interface.bridge must be of type object");

	let obj = {};

	if (exists(value, "mtu")) {
		assert(type(value["mtu"]) == "int", "Property interface.bridge.mtu must be of type integer");
		assert(value["mtu"] <= 65535, "Property interface.bridge.mtu must be <= 65535");
		assert(value["mtu"] >= 256, "Property interface.bridge.mtu must be >= 256");
		obj.mtu = value["mtu"];
	}

	if (exists(value, "tx-queue-len")) {
		assert(type(value["tx-queue-len"]) == "int", "Property interface.bridge.tx-queue-len must be of type integer");
		obj.tx_queue_len = value["tx-queue-len"];
	}

	if (exists(value, "isolate-ports")) {
		assert(type(value["isolate-ports"]) == "bool", "Property interface.bridge.isolate-ports must be of type boolean");
		obj.isolate_ports = value["isolate-ports"];
	}
	else {
		obj.isolate_ports = false;
	}

	return obj;
}

function instantiateInterfaceEthernet(value) {
	assert(type(value) == "object", "Property interface.ethernet must be of type object");

	let obj = {};

	function parseSelectPorts(value) {
		assert(type(value) == "array", "Property interface.ethernet.select-ports must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of interface.ethernet.select-ports must be of type string");
			return item;
		});
	}

	if (exists(value, "select-ports")) {
		obj.select_ports = parseSelectPorts(value["select-ports"]);
	}

	if (exists(value, "multicast")) {
		assert(type(value["multicast"]) == "bool", "Property interface.ethernet.multicast must be of type boolean");
		obj.multicast = value["multicast"];
	}
	else {
		obj.multicast = true;
	}

	if (exists(value, "learning")) {
		assert(type(value["learning"]) == "bool", "Property interface.ethernet.learning must be of type boolean");
		obj.learning = value["learning"];
	}
	else {
		obj.learning = true;
	}

	if (exists(value, "isolate")) {
		assert(type(value["isolate"]) == "bool", "Property interface.ethernet.isolate must be of type boolean");
		obj.isolate = value["isolate"];
	}
	else {
		obj.isolate = false;
	}

	if (exists(value, "macaddr")) {
		assert(type(value["macaddr"]) == "string", "Property interface.ethernet.macaddr must be of type string");
		obj.macaddr = value["macaddr"];
	}

	if (exists(value, "reverse-path-filter")) {
		assert(type(value["reverse-path-filter"]) == "bool", "Property interface.ethernet.reverse-path-filter must be of type boolean");
		obj.reverse_path_filter = value["reverse-path-filter"];
	}
	else {
		obj.reverse_path_filter = false;
	}

	return obj;
}

function instantiateInterfaceIpv4Dhcp(value) {
	assert(type(value) == "object", "Property interface.ipv4.dhcp must be of type object");

	let obj = {};

	if (exists(value, "lease-first")) {
		assert(type(value["lease-first"]) == "int", "Property interface.ipv4.dhcp.lease-first must be of type integer");
		obj.lease_first = value["lease-first"];
	}

	if (exists(value, "lease-count")) {
		assert(type(value["lease-count"]) == "int", "Property interface.ipv4.dhcp.lease-count must be of type integer");
		obj.lease_count = value["lease-count"];
	}

	if (exists(value, "lease-time")) {
		assert(type(value["lease-time"]) == "string", "Property interface.ipv4.dhcp.lease-time must be of type string");
		obj.lease_time = value["lease-time"];
	}
	else {
		obj.lease_time = "6h";
	}

	return obj;
}

function instantiateInterfaceIpv4DhcpLease(value) {
	assert(type(value) == "object", "Property interface.ipv4.dhcp-lease must be of type object");

	let obj = {};

	if (exists(value, "macaddr")) {
		assert(type(value["macaddr"]) == "string", "Property interface.ipv4.dhcp-lease.macaddr must be of type string");
		obj.macaddr = value["macaddr"];
	}

	if (exists(value, "static-lease-offset")) {
		assert(type(value["static-lease-offset"]) == "int", "Property interface.ipv4.dhcp-lease.static-lease-offset must be of type integer");
		obj.static_lease_offset = value["static-lease-offset"];
	}

	if (exists(value, "lease-time")) {
		assert(type(value["lease-time"]) == "string", "Property interface.ipv4.dhcp-lease.lease-time must be of type string");
		obj.lease_time = value["lease-time"];
	}
	else {
		obj.lease_time = "6h";
	}

	if (exists(value, "publish-hostname")) {
		assert(type(value["publish-hostname"]) == "bool", "Property interface.ipv4.dhcp-lease.publish-hostname must be of type boolean");
		obj.publish_hostname = value["publish-hostname"];
	}
	else {
		obj.publish_hostname = true;
	}

	return obj;
}

function instantiateInterfaceIpv4(value) {
	assert(type(value) == "object", "Property interface.ipv4 must be of type object");

	let obj = {};

	if (exists(value, "addressing")) {
		assert(type(value["addressing"]) == "string", "Property interface.ipv4.addressing must be of type string");
		assert(value["addressing"] in [ "dynamic", "static" ], "Property interface.ipv4.addressing must be one of [ \"dynamic\", \"static\" ]");
		obj.addressing = value["addressing"];
	}

	if (exists(value, "subnet")) {
		assert(type(value["subnet"]) == "string", "Property interface.ipv4.subnet must be of type string");
		obj.subnet = value["subnet"];
	}

	if (exists(value, "gateway")) {
		assert(type(value["gateway"]) == "string", "Property interface.ipv4.gateway must be of type string");
		obj.gateway = value["gateway"];
	}

	if (exists(value, "send-hostname")) {
		assert(type(value["send-hostname"]) == "bool", "Property interface.ipv4.send-hostname must be of type boolean");
		obj.send_hostname = value["send-hostname"];
	}
	else {
		obj.send_hostname = true;
	}

	function parseUseDns(value) {
		assert(type(value) == "array", "Property interface.ipv4.use-dns must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of interface.ipv4.use-dns must be of type string");
			return item;
		});
	}

	if (exists(value, "use-dns")) {
		obj.use_dns = parseUseDns(value["use-dns"]);
	}

	if (exists(value, "dhcp")) {
		obj.dhcp = instantiateInterfaceIpv4Dhcp(value["dhcp"]);
	}

	function parseDhcpLeases(value) {
		assert(type(value) == "array", "Property interface.ipv4.dhcp-leases must be of type array");

		return map(value, instantiateInterfaceIpv4DhcpLease);
	}

	if (exists(value, "dhcp-leases")) {
		obj.dhcp_leases = parseDhcpLeases(value["dhcp-leases"]);
	}

	return obj;
}

function instantiateInterfaceSsidEncryption(value) {
	assert(type(value) == "object", "Property interface.ssid.encryption must be of type object");

	let obj = {};

	if (exists(value, "proto")) {
		assert(type(value["proto"]) == "string", "Property interface.ssid.encryption.proto must be of type string");
		assert(value["proto"] in [ "none", "psk", "psk2", "psk-mixed", "wpa", "wpa2", "wpa-mixed", "sae", "sae-mixed", "wpa3", "wpa3-mixed" ], "Property interface.ssid.encryption.proto must be one of [ \"none\", \"psk\", \"psk2\", \"psk-mixed\", \"wpa\", \"wpa2\", \"wpa-mixed\", \"sae\", \"sae-mixed\", \"wpa3\", \"wpa3-mixed\" ]");
		obj.proto = value["proto"];
	}

	if (exists(value, "key")) {
		assert(type(value["key"]) == "string", "Property interface.ssid.encryption.key must be of type string");
		assert(length(value["key"]) <= 63, "Property interface.ssid.encryption.key must be <= 63 characters long");

		assert(length(value["key"]) >= 8, "Property interface.ssid.encryption.key must be >= 8 characters long");

		obj.key = value["key"];
	}

	if (exists(value, "ieee80211w")) {
		assert(type(value["ieee80211w"]) == "string", "Property interface.ssid.encryption.ieee80211w must be of type string");
		assert(value["ieee80211w"] in [ "disabled", "optional", "required" ], "Property interface.ssid.encryption.ieee80211w must be one of [ \"disabled\", \"optional\", \"required\" ]");
		obj.ieee80211w = value["ieee80211w"];
	}
	else {
		obj.ieee80211w = "disabled";
	}

	return obj;
}

function instantiateInterfaceSsidCaptive(value) {
	assert(type(value) == "object", "Property interface.ssid.captive must be of type object");

	let obj = {};

	if (exists(value, "gateway-name")) {
		assert(type(value["gateway-name"]) == "string", "Property interface.ssid.captive.gateway-name must be of type string");
		obj.gateway_name = value["gateway-name"];
	}
	else {
		obj.gateway_name = "uCentral - Captive Portal";
	}

	if (exists(value, "gateway-fqdn")) {
		assert(type(value["gateway-fqdn"]) == "string", "Property interface.ssid.captive.gateway-fqdn must be of type string");
		obj.gateway_fqdn = value["gateway-fqdn"];
	}
	else {
		obj.gateway_fqdn = "ucentral.splash";
	}

	if (exists(value, "maxclients")) {
		assert(type(value["maxclients"]) == "int", "Property interface.ssid.captive.maxclients must be of type integer");
		obj.maxclients = value["maxclients"];
	}
	else {
		obj.maxclients = 32;
	}

	if (exists(value, "upload-rate")) {
		assert(type(value["upload-rate"]) == "int", "Property interface.ssid.captive.upload-rate must be of type integer");
		obj.upload_rate = value["upload-rate"];
	}
	else {
		obj.upload_rate = 10000;
	}

	if (exists(value, "download-rate")) {
		assert(type(value["download-rate"]) == "int", "Property interface.ssid.captive.download-rate must be of type integer");
		obj.download_rate = value["download-rate"];
	}
	else {
		obj.download_rate = 10000;
	}

	if (exists(value, "upload-quota")) {
		assert(type(value["upload-quota"]) == "int", "Property interface.ssid.captive.upload-quota must be of type integer");
		obj.upload_quota = value["upload-quota"];
	}
	else {
		obj.upload_quota = 10000;
	}

	if (exists(value, "download-quota")) {
		assert(type(value["download-quota"]) == "int", "Property interface.ssid.captive.download-quota must be of type integer");
		obj.download_quota = value["download-quota"];
	}
	else {
		obj.download_quota = 10000;
	}

	return obj;
}

function instantiateInterfaceSsidRrm(value) {
	assert(type(value) == "object", "Property interface.ssid.rrm must be of type object");

	let obj = {};

	if (exists(value, "neighbor-reporting")) {
		assert(type(value["neighbor-reporting"]) == "bool", "Property interface.ssid.rrm.neighbor-reporting must be of type boolean");
		obj.neighbor_reporting = value["neighbor-reporting"];
	}
	else {
		obj.neighbor_reporting = false;
	}

	if (exists(value, "lci")) {
		assert(type(value["lci"]) == "string", "Property interface.ssid.rrm.lci must be of type string");
		obj.lci = value["lci"];
	}

	if (exists(value, "civic-location")) {
		assert(type(value["civic-location"]) == "string", "Property interface.ssid.rrm.civic-location must be of type string");
		obj.civic_location = value["civic-location"];
	}

	if (exists(value, "ftm-responder")) {
		assert(type(value["ftm-responder"]) == "bool", "Property interface.ssid.rrm.ftm-responder must be of type boolean");
		obj.ftm_responder = value["ftm-responder"];
	}
	else {
		obj.ftm_responder = false;
	}

	if (exists(value, "stationary-ap")) {
		assert(type(value["stationary-ap"]) == "bool", "Property interface.ssid.rrm.stationary-ap must be of type boolean");
		obj.stationary_ap = value["stationary-ap"];
	}
	else {
		obj.stationary_ap = false;
	}

	return obj;
}

function instantiateInterfaceSsidRates(value) {
	assert(type(value) == "object", "Property interface.ssid.rates must be of type object");

	let obj = {};

	if (exists(value, "beacon")) {
		assert(type(value["beacon"]) == "int", "Property interface.ssid.rates.beacon must be of type integer");
		assert(value["beacon"] in [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ], "Property interface.ssid.rates.beacon must be one of [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]");
		obj.beacon = value["beacon"];
	}
	else {
		obj.beacon = 0;
	}

	if (exists(value, "multicast")) {
		assert(type(value["multicast"]) == "int", "Property interface.ssid.rates.multicast must be of type integer");
		assert(value["multicast"] in [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ], "Property interface.ssid.rates.multicast must be one of [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]");
		obj.multicast = value["multicast"];
	}
	else {
		obj.multicast = 0;
	}

	return obj;
}

function instantiateInterfaceSsidRateLimit(value) {
	assert(type(value) == "object", "Property interface.ssid.rate-limit must be of type object");

	let obj = {};

	if (exists(value, "ingress-rate")) {
		assert(type(value["ingress-rate"]) == "int", "Property interface.ssid.rate-limit.ingress-rate must be of type integer");
		obj.ingress_rate = value["ingress-rate"];
	}
	else {
		obj.ingress_rate = 0;
	}

	if (exists(value, "egress-rate")) {
		assert(type(value["egress-rate"]) == "int", "Property interface.ssid.rate-limit.egress-rate must be of type integer");
		obj.egress_rate = value["egress-rate"];
	}
	else {
		obj.egress_rate = 0;
	}

	return obj;
}

function instantiateInterfaceSsidRoaming(value) {
	assert(type(value) == "object", "Property interface.ssid.roaming must be of type object");

	let obj = {};

	if (exists(value, "message-exchange")) {
		assert(type(value["message-exchange"]) == "string", "Property interface.ssid.roaming.message-exchange must be of type string");
		assert(value["message-exchange"] in [ "air", "ds" ], "Property interface.ssid.roaming.message-exchange must be one of [ \"air\", \"ds\" ]");
		obj.message_exchange = value["message-exchange"];
	}
	else {
		obj.message_exchange = "ds";
	}

	if (exists(value, "generate-psk")) {
		assert(type(value["generate-psk"]) == "bool", "Property interface.ssid.roaming.generate-psk must be of type boolean");
		obj.generate_psk = value["generate-psk"];
	}
	else {
		obj.generate_psk = true;
	}

	if (exists(value, "domain-identifier")) {
		assert(type(value["domain-identifier"]) == "string", "Property interface.ssid.roaming.domain-identifier must be of type string");
		assert(length(value["domain-identifier"]) <= 4, "Property interface.ssid.roaming.domain-identifier must be <= 4 characters long");

		assert(length(value["domain-identifier"]) >= 4, "Property interface.ssid.roaming.domain-identifier must be >= 4 characters long");

		obj.domain_identifier = value["domain-identifier"];
	}

	return obj;
}

function instantiateInterfaceSsidRadiusLocalUser(value) {
	assert(type(value) == "object", "Property interface.ssid.radius.local-user must be of type object");

	let obj = {};

	if (exists(value, "mac")) {
		assert(type(value["mac"]) == "string", "Property interface.ssid.radius.local-user.mac must be of type string");
		obj.mac = value["mac"];
	}

	if (exists(value, "key")) {
		assert(type(value["key"]) == "string", "Property interface.ssid.radius.local-user.key must be of type string");
		assert(length(value["key"]) <= 63, "Property interface.ssid.radius.local-user.key must be <= 63 characters long");

		assert(length(value["key"]) >= 8, "Property interface.ssid.radius.local-user.key must be >= 8 characters long");

		obj.key = value["key"];
	}

	if (exists(value, "vid")) {
		assert(type(value["vid"]) == "int", "Property interface.ssid.radius.local-user.vid must be of type integer");
		assert(value["vid"] <= 4096, "Property interface.ssid.radius.local-user.vid must be <= 4096");
		obj.vid = value["vid"];
	}

	return obj;
}

function instantiateInterfaceSsidRadiusServer(value) {
	assert(type(value) == "object", "Property interface.ssid.radius.server must be of type object");

	let obj = {};

	if (exists(value, "host")) {
		assert(type(value["host"]) == "string", "Property interface.ssid.radius.server.host must be of type string");
		obj.host = value["host"];
	}

	if (exists(value, "port")) {
		assert(type(value["port"]) == "int", "Property interface.ssid.radius.server.port must be of type integer");
		assert(value["port"] <= 65535, "Property interface.ssid.radius.server.port must be <= 65535");
		assert(value["port"] >= 1024, "Property interface.ssid.radius.server.port must be >= 1024");
		obj.port = value["port"];
	}

	if (exists(value, "secret")) {
		assert(type(value["secret"]) == "string", "Property interface.ssid.radius.server.secret must be of type string");
		obj.secret = value["secret"];
	}

	function parseRequestAttribute(value) {
		assert(type(value) == "array", "Property interface.ssid.radius.server.request-attribute must be of type array");

		function parseItem(value) {
			assert(type(value) == "object", "Property interface.ssid.radius.server.request-attribute.item must be of type object");

			let obj = {};

			if (exists(value, "id")) {
				assert(type(value["id"]) == "int", "Property interface.ssid.radius.server.request-attribute.item.id must be of type integer");
				assert(value["id"] <= 255, "Property interface.ssid.radius.server.request-attribute.item.id must be <= 255");
				assert(value["id"] >= 1, "Property interface.ssid.radius.server.request-attribute.item.id must be >= 1");
				obj.id = value["id"];
			}

			function parseValue(value) {
				function parseVariant0(value) {
					assert(type(value) == "int", "Property interface.ssid.radius.server.request-attribute.item.value must be of type integer");
					assert(value <= 4294967295, "Property interface.ssid.radius.server.request-attribute.item.value must be <= 4294967295");
					assert(value >= 0, "Property interface.ssid.radius.server.request-attribute.item.value must be >= 0");

					return value;
				}

				function parseVariant1(value) {
					assert(type(value) == "string", "Property interface.ssid.radius.server.request-attribute.item.value must be of type string");

					return value;
				}

				let success = 0, errors = [];

				try { parseVariant0(value); success++; }
				catch (e) { push(errors, e); }

				try { parseVariant1(value); success++; }
				catch (e) { push(errors, e); }

				assert(success > 0, join("\n- or -\n", errors));

				return value;
			}

			if (exists(value, "value")) {
				obj.value = parseValue(value["value"]);
			}

			return obj;
		}

		return map(value, parseItem);
	}

	if (exists(value, "request-attribute")) {
		obj.request_attribute = parseRequestAttribute(value["request-attribute"]);
	}

	if (exists(value, "request-cui")) {
		assert(type(value["request-cui"]) == "bool", "Property interface.ssid.radius.server.request-cui must be of type boolean");
		obj.request_cui = value["request-cui"];
	}
	else {
		obj.request_cui = false;
	}

	return obj;
}

function instantiateInterfaceSsidRadius(value) {
	assert(type(value) == "object", "Property interface.ssid.radius must be of type object");

	let obj = {};

	function parseLocalUsers(value) {
		assert(type(value) == "array", "Property interface.ssid.radius.local-users must be of type array");

		return map(value, instantiateInterfaceSsidRadiusLocalUser);
	}

	if (exists(value, "local-users")) {
		obj.local_users = parseLocalUsers(value["local-users"]);
	}

	if (exists(value, "authentication")) {
		obj.authentication = instantiateInterfaceSsidRadiusServer(value["authentication"]);
	}

	if (exists(value, "accounting")) {
		obj.accounting = instantiateInterfaceSsidRadiusServer(value["accounting"]);
	}

	return obj;
}

function instantiateInterfaceSsidPassPoint(value) {
	assert(type(value) == "object", "Property interface.ssid.pass-point must be of type object");

	let obj = {};

	if (exists(value, "venue-name")) {
		assert(type(value["venue-name"]) == "string", "Property interface.ssid.pass-point.venue-name must be of type string");
		obj.venue_name = value["venue-name"];
	}

	if (exists(value, "venue-group")) {
		assert(type(value["venue-group"]) == "int", "Property interface.ssid.pass-point.venue-group must be of type integer");
		assert(value["venue-group"] <= 32, "Property interface.ssid.pass-point.venue-group must be <= 32");
		obj.venue_group = value["venue-group"];
	}

	if (exists(value, "venue-type")) {
		assert(type(value["venue-type"]) == "int", "Property interface.ssid.pass-point.venue-type must be of type integer");
		assert(value["venue-type"] <= 32, "Property interface.ssid.pass-point.venue-type must be <= 32");
		obj.venue_type = value["venue-type"];
	}

	if (exists(value, "venue-url")) {
		assert(type(value["venue-url"]) == "string", "Property interface.ssid.pass-point.venue-url must be of type string");
		obj.venue_url = value["venue-url"];
	}

	function parseAuthType(value) {
		assert(type(value) == "object", "Property interface.ssid.pass-point.auth-type must be of type object");

		let obj = {};

		if (exists(value, "type")) {
			assert(type(value["type"]) == "string", "Property interface.ssid.pass-point.auth-type.type must be of type string");
			assert(value["type"] in [ "terms-and-conditions", "online-enrollment", "http-redirection", "dns-redirection" ], "Property interface.ssid.pass-point.auth-type.type must be one of [ \"terms-and-conditions\", \"online-enrollment\", \"http-redirection\", \"dns-redirection\" ]");
			obj.type = value["type"];
		}

		if (exists(value, "uri")) {
			assert(type(value["uri"]) == "string", "Property interface.ssid.pass-point.auth-type.uri must be of type string");
			obj.uri = value["uri"];
		}

		return obj;
	}

	if (exists(value, "auth-type")) {
		obj.auth_type = parseAuthType(value["auth-type"]);
	}

	if (exists(value, "domain-name")) {
		assert(type(value["domain-name"]) == "string", "Property interface.ssid.pass-point.domain-name must be of type string");
		obj.domain_name = value["domain-name"];
	}

	if (exists(value, "nai-realm")) {
		assert(type(value["nai-realm"]) == "string", "Property interface.ssid.pass-point.nai-realm must be of type string");
		obj.nai_realm = value["nai-realm"];
	}

	if (exists(value, "osen")) {
		assert(type(value["osen"]) == "bool", "Property interface.ssid.pass-point.osen must be of type boolean");
		obj.osen = value["osen"];
	}

	if (exists(value, "anqp-domain")) {
		assert(type(value["anqp-domain"]) == "int", "Property interface.ssid.pass-point.anqp-domain must be of type integer");
		assert(value["anqp-domain"] <= 65535, "Property interface.ssid.pass-point.anqp-domain must be <= 65535");
		assert(value["anqp-domain"] >= 0, "Property interface.ssid.pass-point.anqp-domain must be >= 0");
		obj.anqp_domain = value["anqp-domain"];
	}

	if (exists(value, "friendly-name")) {
		assert(type(value["friendly-name"]) == "string", "Property interface.ssid.pass-point.friendly-name must be of type string");
		obj.friendly_name = value["friendly-name"];
	}

	function parseIcon(value) {
		assert(type(value) == "array", "Property interface.ssid.pass-point.icon must be of type array");

		function parseItem(value) {
			assert(type(value) == "object", "Property interface.ssid.pass-point.icon.item must be of type object");

			let obj = {};

			if (exists(value, "width")) {
				assert(type(value["width"]) == "int", "Property interface.ssid.pass-point.icon.item.width must be of type integer");
				obj.width = value["width"];
			}

			if (exists(value, "height")) {
				assert(type(value["height"]) == "int", "Property interface.ssid.pass-point.icon.item.height must be of type integer");
				obj.height = value["height"];
			}

			if (exists(value, "type")) {
				assert(type(value["type"]) == "string", "Property interface.ssid.pass-point.icon.item.type must be of type string");
				obj.type = value["type"];
			}

			if (exists(value, "uri")) {
				assert(type(value["uri"]) == "string", "Property interface.ssid.pass-point.icon.item.uri must be of type string");
				obj.uri = value["uri"];
			}

			if (exists(value, "language")) {
				assert(type(value["language"]) == "string", "Property interface.ssid.pass-point.icon.item.language must be of type string");
				assert(match(value["language"], /^[a-z][a-z][a-z]$/), "Property interface.ssid.pass-point.icon.item.language must match regular expression /^[a-z][a-z][a-z]$/");

				obj.language = value["language"];
			}

			return obj;
		}

		return map(value, parseItem);
	}

	if (exists(value, "icon")) {
		obj.icon = parseIcon(value["icon"]);
	}

	return obj;
}

function instantiateInterfaceSsid(value) {
	assert(type(value) == "object", "Property interface.ssid must be of type object");

	let obj = {};

	if (exists(value, "name")) {
		assert(type(value["name"]) == "string", "Property interface.ssid.name must be of type string");
		assert(length(value["name"]) <= 32, "Property interface.ssid.name must be <= 32 characters long");

		assert(length(value["name"]) >= 1, "Property interface.ssid.name must be >= 1 characters long");

		obj.name = value["name"];
	}

	function parseWifiBands(value) {
		assert(type(value) == "array", "Property interface.ssid.wifi-bands must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of interface.ssid.wifi-bands must be of type string");
			assert(item in [ "2G", "5G", "6G" ], "Items of interface.ssid.wifi-bands must be one of [ \"2G\", \"5G\", \"6G\" ]");
			return item;
		});
	}

	if (exists(value, "wifi-bands")) {
		obj.wifi_bands = parseWifiBands(value["wifi-bands"]);
	}

	if (exists(value, "bss-mode")) {
		assert(type(value["bss-mode"]) == "string", "Property interface.ssid.bss-mode must be of type string");
		assert(value["bss-mode"] in [ "ap", "sta", "mesh", "wds" ], "Property interface.ssid.bss-mode must be one of [ \"ap\", \"sta\", \"mesh\", \"wds\" ]");
		obj.bss_mode = value["bss-mode"];
	}
	else {
		obj.bss_mode = "ap";
	}

	if (exists(value, "bssid")) {
		assert(type(value["bssid"]) == "string", "Property interface.ssid.bssid must be of type string");
		obj.bssid = value["bssid"];
	}

	if (exists(value, "hidden-ssid")) {
		assert(type(value["hidden-ssid"]) == "bool", "Property interface.ssid.hidden-ssid must be of type boolean");
		obj.hidden_ssid = value["hidden-ssid"];
	}

	if (exists(value, "isolate-clients")) {
		assert(type(value["isolate-clients"]) == "bool", "Property interface.ssid.isolate-clients must be of type boolean");
		obj.isolate_clients = value["isolate-clients"];
	}

	if (exists(value, "power-save")) {
		assert(type(value["power-save"]) == "bool", "Property interface.ssid.power-save must be of type boolean");
		obj.power_save = value["power-save"];
	}

	if (exists(value, "rts-threshold")) {
		assert(type(value["rts-threshold"]) == "int", "Property interface.ssid.rts-threshold must be of type integer");
		assert(value["rts-threshold"] <= 65535, "Property interface.ssid.rts-threshold must be <= 65535");
		assert(value["rts-threshold"] >= 1, "Property interface.ssid.rts-threshold must be >= 1");
		obj.rts_threshold = value["rts-threshold"];
	}

	if (exists(value, "broadcast-time")) {
		assert(type(value["broadcast-time"]) == "bool", "Property interface.ssid.broadcast-time must be of type boolean");
		obj.broadcast_time = value["broadcast-time"];
	}

	if (exists(value, "unicast-conversion")) {
		assert(type(value["unicast-conversion"]) == "bool", "Property interface.ssid.unicast-conversion must be of type boolean");
		obj.unicast_conversion = value["unicast-conversion"];
	}

	if (exists(value, "encryption")) {
		obj.encryption = instantiateInterfaceSsidEncryption(value["encryption"]);
	}

	if (exists(value, "captive")) {
		obj.captive = instantiateInterfaceSsidCaptive(value["captive"]);
	}

	if (exists(value, "rrm")) {
		obj.rrm = instantiateInterfaceSsidRrm(value["rrm"]);
	}

	if (exists(value, "rates")) {
		obj.rates = instantiateInterfaceSsidRates(value["rates"]);
	}

	if (exists(value, "rate-limit")) {
		obj.rate_limit = instantiateInterfaceSsidRateLimit(value["rate-limit"]);
	}

	if (exists(value, "roaming")) {
		obj.roaming = instantiateInterfaceSsidRoaming(value["roaming"]);
	}

	if (exists(value, "radius")) {
		obj.radius = instantiateInterfaceSsidRadius(value["radius"]);
	}

	if (exists(value, "pass-point")) {
		obj.pass_point = instantiateInterfaceSsidPassPoint(value["pass-point"]);
	}

	function parseHostapdBssRaw(value) {
		assert(type(value) == "array", "Property interface.ssid.hostapd-bss-raw must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of interface.ssid.hostapd-bss-raw must be of type string");
			return item;
		});
	}

	if (exists(value, "hostapd-bss-raw")) {
		obj.hostapd_bss_raw = parseHostapdBssRaw(value["hostapd-bss-raw"]);
	}

	return obj;
}

function instantiateInterfaceTunnelMesh(value) {
	assert(type(value) == "object", "Property interface.tunnel.mesh must be of type object");

	let obj = {};

	if (exists(value, "proto")) {
		assert(type(value["proto"]) == "string", "Property interface.tunnel.mesh.proto must be of type string");
		assert(value["proto"] in [ "mesh" ], "Property interface.tunnel.mesh.proto must be one of [ \"mesh\" ]");
		obj.proto = value["proto"];
	}

	return obj;
}

function instantiateInterfaceTunnelVxlan(value) {
	assert(type(value) == "object", "Property interface.tunnel.vxlan must be of type object");

	let obj = {};

	if (exists(value, "proto")) {
		assert(type(value["proto"]) == "string", "Property interface.tunnel.vxlan.proto must be of type string");
		assert(value["proto"] in [ "vxlan" ], "Property interface.tunnel.vxlan.proto must be one of [ \"vxlan\" ]");
		obj.proto = value["proto"];
	}

	if (exists(value, "peer-address")) {
		assert(type(value["peer-address"]) == "string", "Property interface.tunnel.vxlan.peer-address must be of type string");
		obj.peer_address = value["peer-address"];
	}

	if (exists(value, "peer-port")) {
		assert(type(value["peer-port"]) == "int", "Property interface.tunnel.vxlan.peer-port must be of type integer");
		assert(value["peer-port"] <= 65535, "Property interface.tunnel.vxlan.peer-port must be <= 65535");
		assert(value["peer-port"] >= 1, "Property interface.tunnel.vxlan.peer-port must be >= 1");
		obj.peer_port = value["peer-port"];
	}

	return obj;
}

function instantiateInterfaceTunnel(value) {
	function parseVariant0(value) {

		let obj = instantiateInterfaceTunnelMesh(value);

		return obj;
	}

	function parseVariant1(value) {

		let obj = instantiateInterfaceTunnelVxlan(value);

		return obj;
	}

	let success = 0, errors = [];

	try { parseVariant0(value); success++; }
	catch (e) { push(errors, e); }

	try { parseVariant1(value); success++; }
	catch (e) { push(errors, e); }

	assert(success == 1, join("\n- or -\n", errors));

	return value;
}

function instantiateInterface(value) {
	assert(type(value) == "object", "Property interface must be of type object");

	let obj = {};

	if (exists(value, "name")) {
		assert(type(value["name"]) == "string", "Property interface.name must be of type string");
		obj.name = value["name"];
	}

	if (exists(value, "role")) {
		assert(type(value["role"]) == "string", "Property interface.role must be of type string");
		assert(value["role"] in [ "upstream", "downstream" ], "Property interface.role must be one of [ \"upstream\", \"downstream\" ]");
		obj.role = value["role"];
	}

	if (exists(value, "isolate-hosts")) {
		assert(type(value["isolate-hosts"]) == "bool", "Property interface.isolate-hosts must be of type boolean");
		obj.isolate_hosts = value["isolate-hosts"];
	}

	if (exists(value, "metric")) {
		assert(type(value["metric"]) == "int", "Property interface.metric must be of type integer");
		assert(value["metric"] <= 4294967295, "Property interface.metric must be <= 4294967295");
		assert(value["metric"] >= 0, "Property interface.metric must be >= 0");
		obj.metric = value["metric"];
	}

	function parseServices(value) {
		assert(type(value) == "array", "Property interface.services must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of interface.services must be of type string");
			return item;
		});
	}

	if (exists(value, "services")) {
		obj.services = parseServices(value["services"]);
	}

	if (exists(value, "vlan")) {
		obj.vlan = instantiateInterfaceVlan(value["vlan"]);
	}

	if (exists(value, "bridge")) {
		obj.bridge = instantiateInterfaceBridge(value["bridge"]);
	}

	function parseEthernet(value) {
		assert(type(value) == "array", "Property interface.ethernet must be of type array");

		return map(value, instantiateInterfaceEthernet);
	}

	if (exists(value, "ethernet")) {
		obj.ethernet = parseEthernet(value["ethernet"]);
	}

	if (exists(value, "ipv4")) {
		obj.ipv4 = instantiateInterfaceIpv4(value["ipv4"]);
	}

	function parseIpv6(value) {

		return value;
	}

	if (exists(value, "ipv6")) {
		obj.ipv6 = parseIpv6(value["ipv6"]);
	}

	function parseSsids(value) {
		assert(type(value) == "array", "Property interface.ssids must be of type array");

		return map(value, instantiateInterfaceSsid);
	}

	if (exists(value, "ssids")) {
		obj.ssids = parseSsids(value["ssids"]);
	}

	if (exists(value, "tunnel")) {
		obj.tunnel = instantiateInterfaceTunnel(value["tunnel"]);
	}

	return obj;
}

function instantiateServiceLldp(value) {
	assert(type(value) == "object", "Property service.lldp must be of type object");

	let obj = {};

	if (exists(value, "describe")) {
		assert(type(value["describe"]) == "string", "Property service.lldp.describe must be of type string");
		obj.describe = value["describe"];
	}
	else {
		obj.describe = "uCentral Access Point";
	}

	if (exists(value, "location")) {
		assert(type(value["location"]) == "string", "Property service.lldp.location must be of type string");
		obj.location = value["location"];
	}
	else {
		obj.location = "uCentral Network";
	}

	return obj;
}

function instantiateServiceSsh(value) {
	assert(type(value) == "object", "Property service.ssh must be of type object");

	let obj = {};

	if (exists(value, "port")) {
		assert(type(value["port"]) == "int", "Property service.ssh.port must be of type integer");
		assert(value["port"] <= 65535, "Property service.ssh.port must be <= 65535");
		obj.port = value["port"];
	}
	else {
		obj.port = 22;
	}

	function parseAuthorizedKeys(value) {
		assert(type(value) == "array", "Property service.ssh.authorized-keys must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of service.ssh.authorized-keys must be of type string");
			return item;
		});
	}

	if (exists(value, "authorized-keys")) {
		obj.authorized_keys = parseAuthorizedKeys(value["authorized-keys"]);
	}

	if (exists(value, "password-authentication")) {
		assert(type(value["password-authentication"]) == "bool", "Property service.ssh.password-authentication must be of type boolean");
		obj.password_authentication = value["password-authentication"];
	}
	else {
		obj.password_authentication = true;
	}

	return obj;
}

function instantiateServiceNtp(value) {
	assert(type(value) == "object", "Property service.ntp must be of type object");

	let obj = {};

	function parseServers(value) {
		assert(type(value) == "array", "Property service.ntp.servers must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of service.ntp.servers must be of type string");
			return item;
		});
	}

	if (exists(value, "servers")) {
		obj.servers = parseServers(value["servers"]);
	}

	if (exists(value, "local-server")) {
		assert(type(value["local-server"]) == "bool", "Property service.ntp.local-server must be of type boolean");
		obj.local_server = value["local-server"];
	}

	return obj;
}

function instantiateServiceMdns(value) {
	assert(type(value) == "object", "Property service.mdns must be of type object");

	let obj = {};

	if (exists(value, "enable")) {
		assert(type(value["enable"]) == "bool", "Property service.mdns.enable must be of type boolean");
		obj.enable = value["enable"];
	}
	else {
		obj.enable = false;
	}

	return obj;
}

function instantiateServiceRtty(value) {
	assert(type(value) == "object", "Property service.rtty must be of type object");

	let obj = {};

	if (exists(value, "host")) {
		assert(type(value["host"]) == "string", "Property service.rtty.host must be of type string");
		obj.host = value["host"];
	}

	if (exists(value, "port")) {
		assert(type(value["port"]) == "int", "Property service.rtty.port must be of type integer");
		assert(value["port"] <= 65535, "Property service.rtty.port must be <= 65535");
		obj.port = value["port"];
	}
	else {
		obj.port = 5912;
	}

	if (exists(value, "token")) {
		assert(type(value["token"]) == "string", "Property service.rtty.token must be of type string");
		assert(length(value["token"]) <= 32, "Property service.rtty.token must be <= 32 characters long");

		assert(length(value["token"]) >= 32, "Property service.rtty.token must be >= 32 characters long");

		obj.token = value["token"];
	}

	return obj;
}

function instantiateServiceLog(value) {
	assert(type(value) == "object", "Property service.log must be of type object");

	let obj = {};

	if (exists(value, "host")) {
		assert(type(value["host"]) == "string", "Property service.log.host must be of type string");
		obj.host = value["host"];
	}

	if (exists(value, "port")) {
		assert(type(value["port"]) == "int", "Property service.log.port must be of type integer");
		assert(value["port"] <= 65535, "Property service.log.port must be <= 65535");
		assert(value["port"] >= 100, "Property service.log.port must be >= 100");
		obj.port = value["port"];
	}

	if (exists(value, "proto")) {
		assert(type(value["proto"]) == "string", "Property service.log.proto must be of type string");
		assert(value["proto"] in [ "tcp", "udp" ], "Property service.log.proto must be one of [ \"tcp\", \"udp\" ]");
		obj.proto = value["proto"];
	}
	else {
		obj.proto = "udp";
	}

	if (exists(value, "size")) {
		assert(type(value["size"]) == "int", "Property service.log.size must be of type integer");
		assert(value["size"] >= 32, "Property service.log.size must be >= 32");
		obj.size = value["size"];
	}
	else {
		obj.size = 1000;
	}

	return obj;
}

function instantiateServiceHttp(value) {
	assert(type(value) == "object", "Property service.http must be of type object");

	let obj = {};

	if (exists(value, "http-port")) {
		assert(type(value["http-port"]) == "int", "Property service.http.http-port must be of type integer");
		assert(value["http-port"] <= 65535, "Property service.http.http-port must be <= 65535");
		assert(value["http-port"] >= 1, "Property service.http.http-port must be >= 1");
		obj.http_port = value["http-port"];
	}
	else {
		obj.http_port = 80;
	}

	return obj;
}

function instantiateServiceIgmp(value) {
	assert(type(value) == "object", "Property service.igmp must be of type object");

	let obj = {};

	if (exists(value, "enable")) {
		assert(type(value["enable"]) == "bool", "Property service.igmp.enable must be of type boolean");
		obj.enable = value["enable"];
	}
	else {
		obj.enable = false;
	}

	return obj;
}

function instantiateServiceWifiSteering(value) {
	assert(type(value) == "object", "Property service.wifi-steering must be of type object");

	let obj = {};

	if (exists(value, "mode")) {
		assert(type(value["mode"]) == "string", "Property service.wifi-steering.mode must be of type string");
		assert(value["mode"] in [ "local", "cloud" ], "Property service.wifi-steering.mode must be one of [ \"local\", \"cloud\" ]");
		obj.mode = value["mode"];
	}

	if (exists(value, "network")) {
		assert(type(value["network"]) == "string", "Property service.wifi-steering.network must be of type string");
		obj.network = value["network"];
	}

	if (exists(value, "key")) {
		assert(type(value["key"]) == "string", "Property service.wifi-steering.key must be of type string");
		obj.key = value["key"];
	}

	return obj;
}

function instantiateService(value) {
	assert(type(value) == "object", "Property service must be of type object");

	let obj = {};

	if (exists(value, "lldp")) {
		obj.lldp = instantiateServiceLldp(value["lldp"]);
	}

	if (exists(value, "ssh")) {
		obj.ssh = instantiateServiceSsh(value["ssh"]);
	}

	if (exists(value, "ntp")) {
		obj.ntp = instantiateServiceNtp(value["ntp"]);
	}

	if (exists(value, "mdns")) {
		obj.mdns = instantiateServiceMdns(value["mdns"]);
	}

	if (exists(value, "rtty")) {
		obj.rtty = instantiateServiceRtty(value["rtty"]);
	}

	if (exists(value, "log")) {
		obj.log = instantiateServiceLog(value["log"]);
	}

	if (exists(value, "http")) {
		obj.http = instantiateServiceHttp(value["http"]);
	}

	if (exists(value, "igmp")) {
		obj.igmp = instantiateServiceIgmp(value["igmp"]);
	}

	if (exists(value, "wifi-steering")) {
		obj.wifi_steering = instantiateServiceWifiSteering(value["wifi-steering"]);
	}

	return obj;
}

function instantiateMetricsStatistics(value) {
	assert(type(value) == "object", "Property metrics.statistics must be of type object");

	let obj = {};

	if (exists(value, "interval")) {
		assert(type(value["interval"]) == "int", "Property metrics.statistics.interval must be of type integer");
		assert(value["interval"] >= 60, "Property metrics.statistics.interval must be >= 60");
		obj.interval = value["interval"];
	}

	function parseTypes(value) {
		assert(type(value) == "array", "Property metrics.statistics.types must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of metrics.statistics.types must be of type string");
			assert(item in [ "ssids", "lldp", "clients" ], "Items of metrics.statistics.types must be one of [ \"ssids\", \"lldp\", \"clients\" ]");
			return item;
		});
	}

	if (exists(value, "types")) {
		obj.types = parseTypes(value["types"]);
	}

	return obj;
}

function instantiateMetricsHealth(value) {
	assert(type(value) == "object", "Property metrics.health must be of type object");

	let obj = {};

	if (exists(value, "interval")) {
		assert(type(value["interval"]) == "int", "Property metrics.health.interval must be of type integer");
		assert(value["interval"] >= 60, "Property metrics.health.interval must be >= 60");
		obj.interval = value["interval"];
	}

	return obj;
}

function instantiateMetricsWifiFrames(value) {
	assert(type(value) == "object", "Property metrics.wifi-frames must be of type object");

	let obj = {};

	function parseFilters(value) {
		assert(type(value) == "array", "Property metrics.wifi-frames.filters must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of metrics.wifi-frames.filters must be of type string");
			assert(item in [ "probe", "auth", "assoc", "disassoc", "deauth", "local-deauth", "inactive-deauth", "key-mismatch", "beacon-report", "radar-detected" ], "Items of metrics.wifi-frames.filters must be one of [ \"probe\", \"auth\", \"assoc\", \"disassoc\", \"deauth\", \"local-deauth\", \"inactive-deauth\", \"key-mismatch\", \"beacon-report\", \"radar-detected\" ]");
			return item;
		});
	}

	if (exists(value, "filters")) {
		obj.filters = parseFilters(value["filters"]);
	}

	return obj;
}

function instantiateMetricsDhcpSnooping(value) {
	assert(type(value) == "object", "Property metrics.dhcp-snooping must be of type object");

	let obj = {};

	function parseFilters(value) {
		assert(type(value) == "array", "Property metrics.dhcp-snooping.filters must be of type array");

		return map(value, (item) => {
			assert(type(item) == "string", "Items of metrics.dhcp-snooping.filters must be of type string");
			assert(item in [ "ack", "discover", "offer", "request", "solicit", "reply", "renew" ], "Items of metrics.dhcp-snooping.filters must be one of [ \"ack\", \"discover\", \"offer\", \"request\", \"solicit\", \"reply\", \"renew\" ]");
			return item;
		});
	}

	if (exists(value, "filters")) {
		obj.filters = parseFilters(value["filters"]);
	}

	return obj;
}

function instantiateMetrics(value) {
	assert(type(value) == "object", "Property metrics must be of type object");

	let obj = {};

	if (exists(value, "statistics")) {
		obj.statistics = instantiateMetricsStatistics(value["statistics"]);
	}

	if (exists(value, "health")) {
		obj.health = instantiateMetricsHealth(value["health"]);
	}

	if (exists(value, "wifi-frames")) {
		obj.wifi_frames = instantiateMetricsWifiFrames(value["wifi-frames"]);
	}

	if (exists(value, "dhcp-snooping")) {
		obj.dhcp_snooping = instantiateMetricsDhcpSnooping(value["dhcp-snooping"]);
	}

	return obj;
}

function instantiateConfigRaw(value) {
	assert(type(value) == "array", "Property config-raw must be of type array");

	function parseItem(value) {
		assert(type(value) == "array", "Property config-raw.item must be of type array");
		assert(length(value) >= 2, "Property config-raw.item array length must be >= 2 items");


		return map(value, (item) => {
			assert(type(item) == "string", "Items of config-raw.item must be of type string");
			return item;
		});
	}

	return map(value, parseItem);
}

function newUCentralState(value) {
	assert(type(value) == "object", "Property UCentralState must be of type object");

	let obj = {};

	if (exists(value, "uuid")) {
		assert(type(value["uuid"]) == "int", "Property UCentralState.uuid must be of type integer");
		obj.uuid = value["uuid"];
	}

	if (exists(value, "unit")) {
		obj.unit = instantiateUnit(value["unit"]);
	}

	if (exists(value, "globals")) {
		obj.globals = instantiateGlobals(value["globals"]);
	}

	if (exists(value, "definitions")) {
		obj.definitions = instantiateDefinitions(value["definitions"]);
	}

	function parseRadios(value) {
		assert(type(value) == "array", "Property UCentralState.radios must be of type array");

		return map(value, instantiateRadio);
	}

	if (exists(value, "radios")) {
		obj.radios = parseRadios(value["radios"]);
	}

	function parseInterfaces(value) {
		assert(type(value) == "array", "Property UCentralState.interfaces must be of type array");

		return map(value, instantiateInterface);
	}

	if (exists(value, "interfaces")) {
		obj.interfaces = parseInterfaces(value["interfaces"]);
	}

	if (exists(value, "services")) {
		obj.services = instantiateService(value["services"]);
	}

	if (exists(value, "metrics")) {
		obj.metrics = instantiateMetrics(value["metrics"]);
	}

	if (exists(value, "config-raw")) {
		obj.config_raw = instantiateConfigRaw(value["config-raw"]);
	}

	return obj;
}

return {
	validate: (value) => newUCentralState(value)
};

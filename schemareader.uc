{%
// Automatically generated from ./ucentral.schema.pretty.json - do not edit!
"use strict";

function matchUcCidr4(value) {
	let m = match(value, /^(auto|[0-9.]+)\/([0-9]+)$/);
	return m ? ((m[1] == "auto" || length(iptoarr(m[1])) == 4) && +m[2] <= 32) : false;
}

function matchUcCidr6(value) {
	let m = match(value, /^(auto|[0-9a-fA-F:.]+)\/([0-9]+)$/);
	return m ? ((m[1] == "auto" || length(iptoarr(m[1])) == 16) && +m[2] <= 128) : false;
}

function matchUcCidr(value) {
	let m = match(value, /^(auto|[0-9a-fA-F:.]+)\/([0-9]+)$/);
	if (!m) return false;
	let l = (m[1] == "auto") ? 16 : length(iptoarr(m[1]));
	return (l > 0 && +m[2] <= (l * 8));
}

function matchUcMac(value) {
	return match(value, /^[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]$/i);
}

function matchUcHost(value) {
	if (length(iptoarr(value)) != 0) return true;
	if (length(value) > 255) return false;
	let labels = split(value, ".");
	return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);
}

function matchUcTimeout(value) {
	return match(value, /^[0-9]+[smhdw]$/);
}

function matchHostname(value) {
	if (length(value) > 255) return false;
	let labels = split(value, ".");
	return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);
}

function matchFqdn(value) {
	if (length(value) > 255) return false;
	let labels = split(value, ".");
	return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 1);
}

function matchIpv4(value) {
	return (length(iptoarr(value)) == 4);
}

function matchIpv6(value) {
	return (length(iptoarr(value)) == 16);
}

function matchUri(value) {
	if (index(value, "data:") == 0) return true;
	let m = match(value, /^[a-z+-]+:\/\/([^\/]+).*$/);
	if (!m) return false;
	if (length(iptoarr(m[1])) != 0) return true;
	if (length(m[1]) > 255) return false;
	let labels = split(m[1], ".");
	return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);
}

function instantiateUnit(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "name")) {
		obj.name = parseName(location + "/name", value["name"], errors);
	}

	function parseLocation(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "location")) {
		obj.location = parseLocation(location + "/location", value["location"], errors);
	}

	function parseTimezone(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "timezone")) {
		obj.timezone = parseTimezone(location + "/timezone", value["timezone"], errors);
	}

	return obj;
}

function instantiateGlobals(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseIpv4Network(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr4(value))
			push(errors, [ location, "must be a valid IPv4 CIDR" ]);

		return value;
	}

	if (exists(value, "ipv4-network")) {
		obj.ipv4_network = parseIpv4Network(location + "/ipv4-network", value["ipv4-network"], errors);
	}

	function parseIpv6Network(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr6(value))
			push(errors, [ location, "must be a valid IPv6 CIDR" ]);

		return value;
	}

	if (exists(value, "ipv6-network")) {
		obj.ipv6_network = parseIpv6Network(location + "/ipv6-network", value["ipv6-network"], errors);
	}

	return obj;
}

function instantiateDefinitions(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseWirelessEncryption(location, value, errors) {
		if (type(value) != "object") {
			push(errors, [ location, "must be of type object" ]);
			return null;
		}

		let obj = {};

		return obj;
	}

	if (exists(value, "wireless-encryption")) {
		obj.wireless_encryption = parseWirelessEncryption(location + "/wireless-encryption", value["wireless-encryption"], errors);
	}

	return obj;
}

function instantiateRadioHe(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMultipleBssid(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "multiple-bssid")) {
		obj.multiple_bssid = parseMultipleBssid(location + "/multiple-bssid", value["multiple-bssid"], errors);
	}
	else {
		obj.multiple_bssid = false;
	}

	function parseEma(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "ema")) {
		obj.ema = parseEma(location + "/ema", value["ema"], errors);
	}
	else {
		obj.ema = false;
	}

	function parseBssColor(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "bss-color")) {
		obj.bss_color = parseBssColor(location + "/bss-color", value["bss-color"], errors);
	}
	else {
		obj.bss_color = 64;
	}

	return obj;
}

function instantiateRadio(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseBand(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "2G", "5G", "6G" ]))
			push(errors, [ location, "must be one of [ \"2G\", \"5G\", \"6G\" ]" ]);

		return value;
	}

	if (exists(value, "band")) {
		obj.band = parseBand(location + "/band", value["band"], errors);
	}

	function parseBandwidth(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (!(value in [ 5, 10, 20 ]))
			push(errors, [ location, "must be one of [ 5, 10, 20 ]" ]);

		return value;
	}

	if (exists(value, "bandwidth")) {
		obj.bandwidth = parseBandwidth(location + "/bandwidth", value["bandwidth"], errors);
	}

	function parseChannel(location, value, errors) {
		function parseVariant0(location, value, errors) {
			if (type(value) != "int") {
				push(errors, [ location, "must be of type integer" ]);
				return null;
			}

			if (value > 171)
				push(errors, [ location, "must be lower than or equal to 171" ]);

			if (value < 1)
				push(errors, [ location, "must be bigger than or equal to 1" ]);

			return value;
		}

		function parseVariant1(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (value != "auto")
				push(errors, [ location, "must have value \"auto\"" ]);

			return value;
		}

		let success = 0, tryval, tryerr, verrors = [];

		tryerr = [];
		tryval = parseVariant0(location, value, tryerr);
		if (!length(tryerr)) {
			value = tryval;
			success++;
		}
		else {
			push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
		}

		tryerr = [];
		tryval = parseVariant1(location, value, tryerr);
		if (!length(tryerr)) {
			value = tryval;
			success++;
		}
		else {
			push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
		}

		if (success != 1) {
			push(errors, [ location, "must match exactly one of the following constraints:\n" + join("\n- or -\n", verrors) ]);
			return null;
		}

		return value;
	}

	if (exists(value, "channel")) {
		obj.channel = parseChannel(location + "/channel", value["channel"], errors);
	}

	function parseCountry(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 2)
			push(errors, [ location, "must be at most 2 characters long" ]);

		if (length(value) < 2)
			push(errors, [ location, "must be at least 2 characters long" ]);

		return value;
	}

	if (exists(value, "country")) {
		obj.country = parseCountry(location + "/country", value["country"], errors);
	}

	function parseChannelMode(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "HT", "VHT", "HE" ]))
			push(errors, [ location, "must be one of [ \"HT\", \"VHT\", \"HE\" ]" ]);

		return value;
	}

	if (exists(value, "channel-mode")) {
		obj.channel_mode = parseChannelMode(location + "/channel-mode", value["channel-mode"], errors);
	}

	function parseChannelWidth(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (!(value in [ 20, 40, 80, 160, 8080 ]))
			push(errors, [ location, "must be one of [ 20, 40, 80, 160, 8080 ]" ]);

		return value;
	}

	if (exists(value, "channel-width")) {
		obj.channel_width = parseChannelWidth(location + "/channel-width", value["channel-width"], errors);
	}

	function parseRequireMode(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "HT", "VHT", "HE" ]))
			push(errors, [ location, "must be one of [ \"HT\", \"VHT\", \"HE\" ]" ]);

		return value;
	}

	if (exists(value, "require-mode")) {
		obj.require_mode = parseRequireMode(location + "/require-mode", value["require-mode"], errors);
	}

	function parseMimo(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "1x1", "2x2", "3x3", "4x4", "5x5", "6x6", "7x7", "8x8" ]))
			push(errors, [ location, "must be one of [ \"1x1\", \"2x2\", \"3x3\", \"4x4\", \"5x5\", \"6x6\", \"7x7\", \"8x8\" ]" ]);

		return value;
	}

	if (exists(value, "mimo")) {
		obj.mimo = parseMimo(location + "/mimo", value["mimo"], errors);
	}

	function parseTxPower(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 30)
			push(errors, [ location, "must be lower than or equal to 30" ]);

		if (value < 0)
			push(errors, [ location, "must be bigger than or equal to 0" ]);

		return value;
	}

	if (exists(value, "tx-power")) {
		obj.tx_power = parseTxPower(location + "/tx-power", value["tx-power"], errors);
	}

	function parseLegacyRates(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "legacy-rates")) {
		obj.legacy_rates = parseLegacyRates(location + "/legacy-rates", value["legacy-rates"], errors);
	}
	else {
		obj.legacy_rates = false;
	}

	function parseBeaconInterval(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 15)
			push(errors, [ location, "must be bigger than or equal to 15" ]);

		return value;
	}

	if (exists(value, "beacon-interval")) {
		obj.beacon_interval = parseBeaconInterval(location + "/beacon-interval", value["beacon-interval"], errors);
	}
	else {
		obj.beacon_interval = 100;
	}

	function parseDtimPeriod(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 255)
			push(errors, [ location, "must be lower than or equal to 255" ]);

		if (value < 1)
			push(errors, [ location, "must be bigger than or equal to 1" ]);

		return value;
	}

	if (exists(value, "dtim-period")) {
		obj.dtim_period = parseDtimPeriod(location + "/dtim-period", value["dtim-period"], errors);
	}
	else {
		obj.dtim_period = 2;
	}

	if (exists(value, "he-settings")) {
		obj.he_settings = instantiateRadioHe(location + "/he-settings", value["he-settings"], errors);
	}

	function parseHostapdIfaceRaw(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "hostapd-iface-raw")) {
		obj.hostapd_iface_raw = parseHostapdIfaceRaw(location + "/hostapd-iface-raw", value["hostapd-iface-raw"], errors);
	}

	return obj;
}

function instantiateInterfaceVlan(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseId(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 4096)
			push(errors, [ location, "must be lower than or equal to 4096" ]);

		if (value < 2)
			push(errors, [ location, "must be bigger than or equal to 2" ]);

		return value;
	}

	if (exists(value, "id")) {
		obj.id = parseId(location + "/id", value["id"], errors);
	}

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "802.1ad", "802.1q" ]))
			push(errors, [ location, "must be one of [ \"802.1ad\", \"802.1q\" ]" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}
	else {
		obj.proto = "802.1q";
	}

	return obj;
}

function instantiateInterfaceBridge(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMtu(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 256)
			push(errors, [ location, "must be bigger than or equal to 256" ]);

		return value;
	}

	if (exists(value, "mtu")) {
		obj.mtu = parseMtu(location + "/mtu", value["mtu"], errors);
	}

	function parseTxQueueLen(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "tx-queue-len")) {
		obj.tx_queue_len = parseTxQueueLen(location + "/tx-queue-len", value["tx-queue-len"], errors);
	}

	function parseIsolatePorts(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "isolate-ports")) {
		obj.isolate_ports = parseIsolatePorts(location + "/isolate-ports", value["isolate-ports"], errors);
	}
	else {
		obj.isolate_ports = false;
	}

	return obj;
}

function instantiateInterfaceEthernet(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseSelectPorts(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "select-ports")) {
		obj.select_ports = parseSelectPorts(location + "/select-ports", value["select-ports"], errors);
	}

	function parseMulticast(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "multicast")) {
		obj.multicast = parseMulticast(location + "/multicast", value["multicast"], errors);
	}
	else {
		obj.multicast = true;
	}

	function parseLearning(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "learning")) {
		obj.learning = parseLearning(location + "/learning", value["learning"], errors);
	}
	else {
		obj.learning = true;
	}

	function parseIsolate(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "isolate")) {
		obj.isolate = parseIsolate(location + "/isolate", value["isolate"], errors);
	}
	else {
		obj.isolate = false;
	}

	function parseMacaddr(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcMac(value))
			push(errors, [ location, "must be a valid MAC address" ]);

		return value;
	}

	if (exists(value, "macaddr")) {
		obj.macaddr = parseMacaddr(location + "/macaddr", value["macaddr"], errors);
	}

	function parseReversePathFilter(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "reverse-path-filter")) {
		obj.reverse_path_filter = parseReversePathFilter(location + "/reverse-path-filter", value["reverse-path-filter"], errors);
	}
	else {
		obj.reverse_path_filter = false;
	}

	return obj;
}

function instantiateInterfaceIpv4Dhcp(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseLeaseFirst(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "lease-first")) {
		obj.lease_first = parseLeaseFirst(location + "/lease-first", value["lease-first"], errors);
	}

	function parseLeaseCount(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "lease-count")) {
		obj.lease_count = parseLeaseCount(location + "/lease-count", value["lease-count"], errors);
	}

	function parseLeaseTime(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcTimeout(value))
			push(errors, [ location, "must be a valid timeout value" ]);

		return value;
	}

	if (exists(value, "lease-time")) {
		obj.lease_time = parseLeaseTime(location + "/lease-time", value["lease-time"], errors);
	}
	else {
		obj.lease_time = "6h";
	}

	return obj;
}

function instantiateInterfaceIpv4DhcpLease(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMacaddr(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcMac(value))
			push(errors, [ location, "must be a valid MAC address" ]);

		return value;
	}

	if (exists(value, "macaddr")) {
		obj.macaddr = parseMacaddr(location + "/macaddr", value["macaddr"], errors);
	}

	function parseStaticLeaseOffset(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "static-lease-offset")) {
		obj.static_lease_offset = parseStaticLeaseOffset(location + "/static-lease-offset", value["static-lease-offset"], errors);
	}

	function parseLeaseTime(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcTimeout(value))
			push(errors, [ location, "must be a valid timeout value" ]);

		return value;
	}

	if (exists(value, "lease-time")) {
		obj.lease_time = parseLeaseTime(location + "/lease-time", value["lease-time"], errors);
	}
	else {
		obj.lease_time = "6h";
	}

	function parsePublishHostname(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "publish-hostname")) {
		obj.publish_hostname = parsePublishHostname(location + "/publish-hostname", value["publish-hostname"], errors);
	}
	else {
		obj.publish_hostname = true;
	}

	return obj;
}

function instantiateInterfaceIpv4(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseAddressing(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "dynamic", "static" ]))
			push(errors, [ location, "must be one of [ \"dynamic\", \"static\" ]" ]);

		return value;
	}

	if (exists(value, "addressing")) {
		obj.addressing = parseAddressing(location + "/addressing", value["addressing"], errors);
	}

	function parseSubnet(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr4(value))
			push(errors, [ location, "must be a valid IPv4 CIDR" ]);

		return value;
	}

	if (exists(value, "subnet")) {
		obj.subnet = parseSubnet(location + "/subnet", value["subnet"], errors);
	}

	function parseGateway(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchIpv4(value))
			push(errors, [ location, "must be a valid IPv4 address" ]);

		return value;
	}

	if (exists(value, "gateway")) {
		obj.gateway = parseGateway(location + "/gateway", value["gateway"], errors);
	}

	function parseSendHostname(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "send-hostname")) {
		obj.send_hostname = parseSendHostname(location + "/send-hostname", value["send-hostname"], errors);
	}
	else {
		obj.send_hostname = true;
	}

	function parseUseDns(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!matchIpv4(value))
				push(errors, [ location, "must be a valid IPv4 address" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "use-dns")) {
		obj.use_dns = parseUseDns(location + "/use-dns", value["use-dns"], errors);
	}

	if (exists(value, "dhcp")) {
		obj.dhcp = instantiateInterfaceIpv4Dhcp(location + "/dhcp", value["dhcp"], errors);
	}

	function parseDhcpLeases(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterfaceIpv4DhcpLease(location + "/" + i, item, errors));
	}

	if (exists(value, "dhcp-leases")) {
		obj.dhcp_leases = parseDhcpLeases(location + "/dhcp-leases", value["dhcp-leases"], errors);
	}

	return obj;
}

function instantiateInterfaceIpv6Dhcpv6(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMode(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "hybrid", "stateless", "stateful", "relay" ]))
			push(errors, [ location, "must be one of [ \"hybrid\", \"stateless\", \"stateful\", \"relay\" ]" ]);

		return value;
	}

	if (exists(value, "mode")) {
		obj.mode = parseMode(location + "/mode", value["mode"], errors);
	}

	function parseAnnounceDns(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!matchIpv6(value))
				push(errors, [ location, "must be a valid IPv6 address" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "announce-dns")) {
		obj.announce_dns = parseAnnounceDns(location + "/announce-dns", value["announce-dns"], errors);
	}

	function parseFilterPrefix(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr6(value))
			push(errors, [ location, "must be a valid IPv6 CIDR" ]);

		return value;
	}

	if (exists(value, "filter-prefix")) {
		obj.filter_prefix = parseFilterPrefix(location + "/filter-prefix", value["filter-prefix"], errors);
	}
	else {
		obj.filter_prefix = "::/0";
	}

	return obj;
}

function instantiateInterfaceIpv6(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseAddressing(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "dynamic", "static" ]))
			push(errors, [ location, "must be one of [ \"dynamic\", \"static\" ]" ]);

		return value;
	}

	if (exists(value, "addressing")) {
		obj.addressing = parseAddressing(location + "/addressing", value["addressing"], errors);
	}

	function parseSubnet(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr6(value))
			push(errors, [ location, "must be a valid IPv6 CIDR" ]);

		return value;
	}

	if (exists(value, "subnet")) {
		obj.subnet = parseSubnet(location + "/subnet", value["subnet"], errors);
	}

	function parseGateway(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchIpv6(value))
			push(errors, [ location, "must be a valid IPv6 address" ]);

		return value;
	}

	if (exists(value, "gateway")) {
		obj.gateway = parseGateway(location + "/gateway", value["gateway"], errors);
	}

	function parsePrefixSize(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 64)
			push(errors, [ location, "must be lower than or equal to 64" ]);

		if (value < 0)
			push(errors, [ location, "must be bigger than or equal to 0" ]);

		return value;
	}

	if (exists(value, "prefix-size")) {
		obj.prefix_size = parsePrefixSize(location + "/prefix-size", value["prefix-size"], errors);
	}

	if (exists(value, "dhcpv6")) {
		obj.dhcpv6 = instantiateInterfaceIpv6Dhcpv6(location + "/dhcpv6", value["dhcpv6"], errors);
	}

	return obj;
}

function instantiateInterfaceCaptive(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseGatewayName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "gateway-name")) {
		obj.gateway_name = parseGatewayName(location + "/gateway-name", value["gateway-name"], errors);
	}
	else {
		obj.gateway_name = "uCentral - Captive Portal";
	}

	function parseGatewayFqdn(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchFqdn(value))
			push(errors, [ location, "must be a valid fully qualified domain name" ]);

		return value;
	}

	if (exists(value, "gateway-fqdn")) {
		obj.gateway_fqdn = parseGatewayFqdn(location + "/gateway-fqdn", value["gateway-fqdn"], errors);
	}
	else {
		obj.gateway_fqdn = "ucentral.splash";
	}

	function parseMaxClients(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "max-clients")) {
		obj.max_clients = parseMaxClients(location + "/max-clients", value["max-clients"], errors);
	}
	else {
		obj.max_clients = 32;
	}

	function parseUploadRate(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "upload-rate")) {
		obj.upload_rate = parseUploadRate(location + "/upload-rate", value["upload-rate"], errors);
	}
	else {
		obj.upload_rate = 0;
	}

	function parseDownloadRate(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "download-rate")) {
		obj.download_rate = parseDownloadRate(location + "/download-rate", value["download-rate"], errors);
	}
	else {
		obj.download_rate = 0;
	}

	function parseUploadQuota(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "upload-quota")) {
		obj.upload_quota = parseUploadQuota(location + "/upload-quota", value["upload-quota"], errors);
	}
	else {
		obj.upload_quota = 0;
	}

	function parseDownloadQuota(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "download-quota")) {
		obj.download_quota = parseDownloadQuota(location + "/download-quota", value["download-quota"], errors);
	}
	else {
		obj.download_quota = 0;
	}

	return obj;
}

function instantiateInterfaceSsidEncryption(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "none", "psk", "psk2", "psk-mixed", "wpa", "wpa2", "wpa-mixed", "sae", "sae-mixed", "wpa3", "wpa3-mixed" ]))
			push(errors, [ location, "must be one of [ \"none\", \"psk\", \"psk2\", \"psk-mixed\", \"wpa\", \"wpa2\", \"wpa-mixed\", \"sae\", \"sae-mixed\", \"wpa3\", \"wpa3-mixed\" ]" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}

	function parseKey(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 63)
			push(errors, [ location, "must be at most 63 characters long" ]);

		if (length(value) < 8)
			push(errors, [ location, "must be at least 63 characters long" ]);

		return value;
	}

	if (exists(value, "key")) {
		obj.key = parseKey(location + "/key", value["key"], errors);
	}

	function parseIeee80211w(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "disabled", "optional", "required" ]))
			push(errors, [ location, "must be one of [ \"disabled\", \"optional\", \"required\" ]" ]);

		return value;
	}

	if (exists(value, "ieee80211w")) {
		obj.ieee80211w = parseIeee80211w(location + "/ieee80211w", value["ieee80211w"], errors);
	}
	else {
		obj.ieee80211w = "disabled";
	}

	return obj;
}

function instantiateInterfaceSsidMultiPsk(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMac(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcMac(value))
			push(errors, [ location, "must be a valid MAC address" ]);

		return value;
	}

	if (exists(value, "mac")) {
		obj.mac = parseMac(location + "/mac", value["mac"], errors);
	}

	function parseKey(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 63)
			push(errors, [ location, "must be at most 63 characters long" ]);

		if (length(value) < 8)
			push(errors, [ location, "must be at least 63 characters long" ]);

		return value;
	}

	if (exists(value, "key")) {
		obj.key = parseKey(location + "/key", value["key"], errors);
	}

	function parseVlanId(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 4096)
			push(errors, [ location, "must be lower than or equal to 4096" ]);

		return value;
	}

	if (exists(value, "vlan-id")) {
		obj.vlan_id = parseVlanId(location + "/vlan-id", value["vlan-id"], errors);
	}

	return obj;
}

function instantiateInterfaceSsidRrm(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseNeighborReporting(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "neighbor-reporting")) {
		obj.neighbor_reporting = parseNeighborReporting(location + "/neighbor-reporting", value["neighbor-reporting"], errors);
	}
	else {
		obj.neighbor_reporting = false;
	}

	function parseLci(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "lci")) {
		obj.lci = parseLci(location + "/lci", value["lci"], errors);
	}

	function parseCivicLocation(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "civic-location")) {
		obj.civic_location = parseCivicLocation(location + "/civic-location", value["civic-location"], errors);
	}

	function parseFtmResponder(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "ftm-responder")) {
		obj.ftm_responder = parseFtmResponder(location + "/ftm-responder", value["ftm-responder"], errors);
	}
	else {
		obj.ftm_responder = false;
	}

	function parseStationaryAp(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "stationary-ap")) {
		obj.stationary_ap = parseStationaryAp(location + "/stationary-ap", value["stationary-ap"], errors);
	}
	else {
		obj.stationary_ap = false;
	}

	return obj;
}

function instantiateInterfaceSsidRates(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseBeacon(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (!(value in [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]))
			push(errors, [ location, "must be one of [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]" ]);

		return value;
	}

	if (exists(value, "beacon")) {
		obj.beacon = parseBeacon(location + "/beacon", value["beacon"], errors);
	}
	else {
		obj.beacon = 0;
	}

	function parseMulticast(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (!(value in [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]))
			push(errors, [ location, "must be one of [ 0, 1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000 ]" ]);

		return value;
	}

	if (exists(value, "multicast")) {
		obj.multicast = parseMulticast(location + "/multicast", value["multicast"], errors);
	}
	else {
		obj.multicast = 0;
	}

	return obj;
}

function instantiateInterfaceSsidRateLimit(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseIngressRate(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "ingress-rate")) {
		obj.ingress_rate = parseIngressRate(location + "/ingress-rate", value["ingress-rate"], errors);
	}
	else {
		obj.ingress_rate = 0;
	}

	function parseEgressRate(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "egress-rate")) {
		obj.egress_rate = parseEgressRate(location + "/egress-rate", value["egress-rate"], errors);
	}
	else {
		obj.egress_rate = 0;
	}

	return obj;
}

function instantiateInterfaceSsidRoaming(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMessageExchange(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "air", "ds" ]))
			push(errors, [ location, "must be one of [ \"air\", \"ds\" ]" ]);

		return value;
	}

	if (exists(value, "message-exchange")) {
		obj.message_exchange = parseMessageExchange(location + "/message-exchange", value["message-exchange"], errors);
	}
	else {
		obj.message_exchange = "ds";
	}

	function parseGeneratePsk(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "generate-psk")) {
		obj.generate_psk = parseGeneratePsk(location + "/generate-psk", value["generate-psk"], errors);
	}
	else {
		obj.generate_psk = true;
	}

	function parseDomainIdentifier(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 4)
			push(errors, [ location, "must be at most 4 characters long" ]);

		if (length(value) < 4)
			push(errors, [ location, "must be at least 4 characters long" ]);

		return value;
	}

	if (exists(value, "domain-identifier")) {
		obj.domain_identifier = parseDomainIdentifier(location + "/domain-identifier", value["domain-identifier"], errors);
	}

	return obj;
}

function instantiateInterfaceSsidRadiusLocalUser(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMac(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcMac(value))
			push(errors, [ location, "must be a valid MAC address" ]);

		return value;
	}

	if (exists(value, "mac")) {
		obj.mac = parseMac(location + "/mac", value["mac"], errors);
	}

	function parseUser(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 63)
			push(errors, [ location, "must be at most 63 characters long" ]);

		if (length(value) < 8)
			push(errors, [ location, "must be at least 63 characters long" ]);

		return value;
	}

	if (exists(value, "user")) {
		obj.user = parseUser(location + "/user", value["user"], errors);
	}

	function parsePsk(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 63)
			push(errors, [ location, "must be at most 63 characters long" ]);

		if (length(value) < 8)
			push(errors, [ location, "must be at least 63 characters long" ]);

		return value;
	}

	if (exists(value, "psk")) {
		obj.psk = parsePsk(location + "/psk", value["psk"], errors);
	}

	function parseVid(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 4096)
			push(errors, [ location, "must be lower than or equal to 4096" ]);

		return value;
	}

	if (exists(value, "vid")) {
		obj.vid = parseVid(location + "/vid", value["vid"], errors);
	}

	return obj;
}

function instantiateInterfaceSsidRadiusServer(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseHost(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcHost(value))
			push(errors, [ location, "must be a valid hostname or IP address" ]);

		return value;
	}

	if (exists(value, "host")) {
		obj.host = parseHost(location + "/host", value["host"], errors);
	}

	function parsePort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 1024)
			push(errors, [ location, "must be bigger than or equal to 1024" ]);

		return value;
	}

	if (exists(value, "port")) {
		obj.port = parsePort(location + "/port", value["port"], errors);
	}

	function parseSecret(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "secret")) {
		obj.secret = parseSecret(location + "/secret", value["secret"], errors);
	}

	function parseRequestAttribute(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "object") {
				push(errors, [ location, "must be of type object" ]);
				return null;
			}

			let obj = {};

			function parseId(location, value, errors) {
				if (type(value) != "int") {
					push(errors, [ location, "must be of type integer" ]);
					return null;
				}

				if (value > 255)
					push(errors, [ location, "must be lower than or equal to 255" ]);

				if (value < 1)
					push(errors, [ location, "must be bigger than or equal to 1" ]);

				return value;
			}

			if (exists(value, "id")) {
				obj.id = parseId(location + "/id", value["id"], errors);
			}

			function parseValue(location, value, errors) {
				function parseVariant0(location, value, errors) {
					if (type(value) != "int") {
						push(errors, [ location, "must be of type integer" ]);
						return null;
					}

					if (value > 4294967295)
						push(errors, [ location, "must be lower than or equal to 4294967295" ]);

					if (value < 0)
						push(errors, [ location, "must be bigger than or equal to 0" ]);

					return value;
				}

				function parseVariant1(location, value, errors) {
					if (type(value) != "string") {
						push(errors, [ location, "must be of type string" ]);
						return null;
					}

					return value;
				}

				let success = 0, tryval, tryerr, verrors = [];

				tryerr = [];
				tryval = parseVariant0(location, value, tryerr);
				if (!length(tryerr)) {
					value = tryval;
					success++;
				}
				else {
					push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
				}

				tryerr = [];
				tryval = parseVariant1(location, value, tryerr);
				if (!length(tryerr)) {
					value = tryval;
					success++;
				}
				else {
					push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
				}

				if (success == 0) {
					push(errors, [ location, "must match at least one of the following constraints:\n" + join("\n- or -\n", verrors) ]);
					return null;
				}

				return value;
			}

			if (exists(value, "value")) {
				obj.value = parseValue(location + "/value", value["value"], errors);
			}

			return obj;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "request-attribute")) {
		obj.request_attribute = parseRequestAttribute(location + "/request-attribute", value["request-attribute"], errors);
	}

	function parseRequestCui(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "request-cui")) {
		obj.request_cui = parseRequestCui(location + "/request-cui", value["request-cui"], errors);
	}
	else {
		obj.request_cui = false;
	}

	return obj;
}

function instantiateInterfaceSsidRadius(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseLocalUsers(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterfaceSsidRadiusLocalUser(location + "/" + i, item, errors));
	}

	if (exists(value, "local-users")) {
		obj.local_users = parseLocalUsers(location + "/local-users", value["local-users"], errors);
	}

	if (exists(value, "authentication")) {
		obj.authentication = instantiateInterfaceSsidRadiusServer(location + "/authentication", value["authentication"], errors);
	}

	if (exists(value, "accounting")) {
		obj.accounting = instantiateInterfaceSsidRadiusServer(location + "/accounting", value["accounting"], errors);
	}

	return obj;
}

function instantiateInterfaceSsidPassPoint(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseVenueName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "venue-name")) {
		obj.venue_name = parseVenueName(location + "/venue-name", value["venue-name"], errors);
	}

	function parseVenueGroup(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 32)
			push(errors, [ location, "must be lower than or equal to 32" ]);

		return value;
	}

	if (exists(value, "venue-group")) {
		obj.venue_group = parseVenueGroup(location + "/venue-group", value["venue-group"], errors);
	}

	function parseVenueType(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 32)
			push(errors, [ location, "must be lower than or equal to 32" ]);

		return value;
	}

	if (exists(value, "venue-type")) {
		obj.venue_type = parseVenueType(location + "/venue-type", value["venue-type"], errors);
	}

	function parseVenueUrl(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUri(value))
			push(errors, [ location, "must be a valid URI" ]);

		return value;
	}

	if (exists(value, "venue-url")) {
		obj.venue_url = parseVenueUrl(location + "/venue-url", value["venue-url"], errors);
	}

	function parseAuthType(location, value, errors) {
		if (type(value) != "object") {
			push(errors, [ location, "must be of type object" ]);
			return null;
		}

		let obj = {};

		function parseType(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!(value in [ "terms-and-conditions", "online-enrollment", "http-redirection", "dns-redirection" ]))
				push(errors, [ location, "must be one of [ \"terms-and-conditions\", \"online-enrollment\", \"http-redirection\", \"dns-redirection\" ]" ]);

			return value;
		}

		if (exists(value, "type")) {
			obj.type = parseType(location + "/type", value["type"], errors);
		}

		function parseUri(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!matchUri(value))
				push(errors, [ location, "must be a valid URI" ]);

			return value;
		}

		if (exists(value, "uri")) {
			obj.uri = parseUri(location + "/uri", value["uri"], errors);
		}

		return obj;
	}

	if (exists(value, "auth-type")) {
		obj.auth_type = parseAuthType(location + "/auth-type", value["auth-type"], errors);
	}

	function parseDomainName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchHostname(value))
			push(errors, [ location, "must be a valid hostname" ]);

		return value;
	}

	if (exists(value, "domain-name")) {
		obj.domain_name = parseDomainName(location + "/domain-name", value["domain-name"], errors);
	}

	function parseNaiRealm(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "nai-realm")) {
		obj.nai_realm = parseNaiRealm(location + "/nai-realm", value["nai-realm"], errors);
	}

	function parseOsen(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "osen")) {
		obj.osen = parseOsen(location + "/osen", value["osen"], errors);
	}

	function parseAnqpDomain(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 0)
			push(errors, [ location, "must be bigger than or equal to 0" ]);

		return value;
	}

	if (exists(value, "anqp-domain")) {
		obj.anqp_domain = parseAnqpDomain(location + "/anqp-domain", value["anqp-domain"], errors);
	}

	function parseFriendlyName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "friendly-name")) {
		obj.friendly_name = parseFriendlyName(location + "/friendly-name", value["friendly-name"], errors);
	}

	function parseIcon(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "object") {
				push(errors, [ location, "must be of type object" ]);
				return null;
			}

			let obj = {};

			function parseWidth(location, value, errors) {
				if (type(value) != "int") {
					push(errors, [ location, "must be of type integer" ]);
					return null;
				}

				return value;
			}

			if (exists(value, "width")) {
				obj.width = parseWidth(location + "/width", value["width"], errors);
			}

			function parseHeight(location, value, errors) {
				if (type(value) != "int") {
					push(errors, [ location, "must be of type integer" ]);
					return null;
				}

				return value;
			}

			if (exists(value, "height")) {
				obj.height = parseHeight(location + "/height", value["height"], errors);
			}

			function parseType(location, value, errors) {
				if (type(value) != "string") {
					push(errors, [ location, "must be of type string" ]);
					return null;
				}

				return value;
			}

			if (exists(value, "type")) {
				obj.type = parseType(location + "/type", value["type"], errors);
			}

			function parseUri(location, value, errors) {
				if (type(value) != "string") {
					push(errors, [ location, "must be of type string" ]);
					return null;
				}

				if (!matchUri(value))
					push(errors, [ location, "must be a valid URI" ]);

				return value;
			}

			if (exists(value, "uri")) {
				obj.uri = parseUri(location + "/uri", value["uri"], errors);
			}

			function parseLanguage(location, value, errors) {
				if (type(value) != "string") {
					push(errors, [ location, "must be of type string" ]);
					return null;
				}

				if (!match(value, regexp("^[a-z][a-z][a-z]$")))
					push(errors, [ location, "must match regular expression /^[a-z][a-z][a-z]$/" ]);

				return value;
			}

			if (exists(value, "language")) {
				obj.language = parseLanguage(location + "/language", value["language"], errors);
			}

			return obj;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "icon")) {
		obj.icon = parseIcon(location + "/icon", value["icon"], errors);
	}

	return obj;
}

function instantiateInterfaceSsid(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 32)
			push(errors, [ location, "must be at most 32 characters long" ]);

		if (length(value) < 1)
			push(errors, [ location, "must be at least 32 characters long" ]);

		return value;
	}

	if (exists(value, "name")) {
		obj.name = parseName(location + "/name", value["name"], errors);
	}

	function parseWifiBands(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!(value in [ "2G", "5G", "6G" ]))
				push(errors, [ location, "must be one of [ \"2G\", \"5G\", \"6G\" ]" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "wifi-bands")) {
		obj.wifi_bands = parseWifiBands(location + "/wifi-bands", value["wifi-bands"], errors);
	}

	function parseBssMode(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "ap", "sta", "mesh", "wds-ap", "wds-sta", "wds-repeater" ]))
			push(errors, [ location, "must be one of [ \"ap\", \"sta\", \"mesh\", \"wds-ap\", \"wds-sta\", \"wds-repeater\" ]" ]);

		return value;
	}

	if (exists(value, "bss-mode")) {
		obj.bss_mode = parseBssMode(location + "/bss-mode", value["bss-mode"], errors);
	}
	else {
		obj.bss_mode = "ap";
	}

	function parseBssid(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcMac(value))
			push(errors, [ location, "must be a valid MAC address" ]);

		return value;
	}

	if (exists(value, "bssid")) {
		obj.bssid = parseBssid(location + "/bssid", value["bssid"], errors);
	}

	function parseHiddenSsid(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "hidden-ssid")) {
		obj.hidden_ssid = parseHiddenSsid(location + "/hidden-ssid", value["hidden-ssid"], errors);
	}

	function parseIsolateClients(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "isolate-clients")) {
		obj.isolate_clients = parseIsolateClients(location + "/isolate-clients", value["isolate-clients"], errors);
	}

	function parsePowerSave(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "power-save")) {
		obj.power_save = parsePowerSave(location + "/power-save", value["power-save"], errors);
	}

	function parseRtsThreshold(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 1)
			push(errors, [ location, "must be bigger than or equal to 1" ]);

		return value;
	}

	if (exists(value, "rts-threshold")) {
		obj.rts_threshold = parseRtsThreshold(location + "/rts-threshold", value["rts-threshold"], errors);
	}

	function parseBroadcastTime(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "broadcast-time")) {
		obj.broadcast_time = parseBroadcastTime(location + "/broadcast-time", value["broadcast-time"], errors);
	}

	function parseUnicastConversion(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "unicast-conversion")) {
		obj.unicast_conversion = parseUnicastConversion(location + "/unicast-conversion", value["unicast-conversion"], errors);
	}

	function parseServices(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "services")) {
		obj.services = parseServices(location + "/services", value["services"], errors);
	}

	if (exists(value, "encryption")) {
		obj.encryption = instantiateInterfaceSsidEncryption(location + "/encryption", value["encryption"], errors);
	}

	function parseMultiPsk(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterfaceSsidMultiPsk(location + "/" + i, item, errors));
	}

	if (exists(value, "multi-psk")) {
		obj.multi_psk = parseMultiPsk(location + "/multi-psk", value["multi-psk"], errors);
	}

	if (exists(value, "rrm")) {
		obj.rrm = instantiateInterfaceSsidRrm(location + "/rrm", value["rrm"], errors);
	}

	if (exists(value, "rates")) {
		obj.rates = instantiateInterfaceSsidRates(location + "/rates", value["rates"], errors);
	}

	if (exists(value, "rate-limit")) {
		obj.rate_limit = instantiateInterfaceSsidRateLimit(location + "/rate-limit", value["rate-limit"], errors);
	}

	if (exists(value, "roaming")) {
		obj.roaming = instantiateInterfaceSsidRoaming(location + "/roaming", value["roaming"], errors);
	}

	if (exists(value, "radius")) {
		obj.radius = instantiateInterfaceSsidRadius(location + "/radius", value["radius"], errors);
	}

	if (exists(value, "pass-point")) {
		obj.pass_point = instantiateInterfaceSsidPassPoint(location + "/pass-point", value["pass-point"], errors);
	}

	function parseHostapdBssRaw(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "hostapd-bss-raw")) {
		obj.hostapd_bss_raw = parseHostapdBssRaw(location + "/hostapd-bss-raw", value["hostapd-bss-raw"], errors);
	}

	return obj;
}

function instantiateInterfaceTunnelMesh(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (value != "mesh")
			push(errors, [ location, "must have value \"mesh\"" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}

	return obj;
}

function instantiateInterfaceTunnelVxlan(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (value != "vxlan")
			push(errors, [ location, "must have value \"vxlan\"" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}

	function parsePeerAddress(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr4(value))
			push(errors, [ location, "must be a valid IPv4 CIDR" ]);

		return value;
	}

	if (exists(value, "peer-address")) {
		obj.peer_address = parsePeerAddress(location + "/peer-address", value["peer-address"], errors);
	}

	function parsePeerPort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 1)
			push(errors, [ location, "must be bigger than or equal to 1" ]);

		return value;
	}

	if (exists(value, "peer-port")) {
		obj.peer_port = parsePeerPort(location + "/peer-port", value["peer-port"], errors);
	}

	return obj;
}

function instantiateInterfaceTunnelGre(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (value != "gre")
			push(errors, [ location, "must have value \"gre\"" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}

	function parsePeerAddress(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcCidr4(value))
			push(errors, [ location, "must be a valid IPv4 CIDR" ]);

		return value;
	}

	if (exists(value, "peer-address")) {
		obj.peer_address = parsePeerAddress(location + "/peer-address", value["peer-address"], errors);
	}

	function parseVlanId(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 4096)
			push(errors, [ location, "must be lower than or equal to 4096" ]);

		return value;
	}

	if (exists(value, "vlan-id")) {
		obj.vlan_id = parseVlanId(location + "/vlan-id", value["vlan-id"], errors);
	}

	return obj;
}

function instantiateInterfaceTunnel(location, value, errors) {
	function parseVariant0(location, value, errors) {
		let obj = instantiateInterfaceTunnelMesh(location, value, errors);

		return obj;
	}

	function parseVariant1(location, value, errors) {
		let obj = instantiateInterfaceTunnelVxlan(location, value, errors);

		return obj;
	}

	function parseVariant2(location, value, errors) {
		let obj = instantiateInterfaceTunnelGre(location, value, errors);

		return obj;
	}

	let success = 0, tryval, tryerr, verrors = [];

	tryerr = [];
	tryval = parseVariant0(location, value, tryerr);
	if (!length(tryerr)) {
		value = tryval;
		success++;
	}
	else {
		push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
	}

	tryerr = [];
	tryval = parseVariant1(location, value, tryerr);
	if (!length(tryerr)) {
		value = tryval;
		success++;
	}
	else {
		push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
	}

	tryerr = [];
	tryval = parseVariant2(location, value, tryerr);
	if (!length(tryerr)) {
		value = tryval;
		success++;
	}
	else {
		push(verrors, join(" and\n", map(tryerr, err => "\t - " + err[1])));
	}

	if (success != 1) {
		push(errors, [ location, "must match exactly one of the following constraints:\n" + join("\n- or -\n", verrors) ]);
		return null;
	}

	return value;
}

function instantiateInterface(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseName(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "name")) {
		obj.name = parseName(location + "/name", value["name"], errors);
	}

	function parseRole(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "upstream", "downstream" ]))
			push(errors, [ location, "must be one of [ \"upstream\", \"downstream\" ]" ]);

		return value;
	}

	if (exists(value, "role")) {
		obj.role = parseRole(location + "/role", value["role"], errors);
	}

	function parseIsolateHosts(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "isolate-hosts")) {
		obj.isolate_hosts = parseIsolateHosts(location + "/isolate-hosts", value["isolate-hosts"], errors);
	}

	function parseMetric(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 4294967295)
			push(errors, [ location, "must be lower than or equal to 4294967295" ]);

		if (value < 0)
			push(errors, [ location, "must be bigger than or equal to 0" ]);

		return value;
	}

	if (exists(value, "metric")) {
		obj.metric = parseMetric(location + "/metric", value["metric"], errors);
	}

	function parseServices(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "services")) {
		obj.services = parseServices(location + "/services", value["services"], errors);
	}

	if (exists(value, "vlan")) {
		obj.vlan = instantiateInterfaceVlan(location + "/vlan", value["vlan"], errors);
	}

	if (exists(value, "bridge")) {
		obj.bridge = instantiateInterfaceBridge(location + "/bridge", value["bridge"], errors);
	}

	function parseEthernet(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterfaceEthernet(location + "/" + i, item, errors));
	}

	if (exists(value, "ethernet")) {
		obj.ethernet = parseEthernet(location + "/ethernet", value["ethernet"], errors);
	}

	if (exists(value, "ipv4")) {
		obj.ipv4 = instantiateInterfaceIpv4(location + "/ipv4", value["ipv4"], errors);
	}

	if (exists(value, "ipv6")) {
		obj.ipv6 = instantiateInterfaceIpv6(location + "/ipv6", value["ipv6"], errors);
	}

	if (exists(value, "captive")) {
		obj.captive = instantiateInterfaceCaptive(location + "/captive", value["captive"], errors);
	}

	function parseSsids(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterfaceSsid(location + "/" + i, item, errors));
	}

	if (exists(value, "ssids")) {
		obj.ssids = parseSsids(location + "/ssids", value["ssids"], errors);
	}

	if (exists(value, "tunnel")) {
		obj.tunnel = instantiateInterfaceTunnel(location + "/tunnel", value["tunnel"], errors);
	}

	return obj;
}

function instantiateServiceLldp(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseDescribe(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "describe")) {
		obj.describe = parseDescribe(location + "/describe", value["describe"], errors);
	}
	else {
		obj.describe = "uCentral Access Point";
	}

	function parseLocation(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "location")) {
		obj.location = parseLocation(location + "/location", value["location"], errors);
	}
	else {
		obj.location = "uCentral Network";
	}

	return obj;
}

function instantiateServiceSsh(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parsePort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		return value;
	}

	if (exists(value, "port")) {
		obj.port = parsePort(location + "/port", value["port"], errors);
	}
	else {
		obj.port = 22;
	}

	function parseAuthorizedKeys(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "authorized-keys")) {
		obj.authorized_keys = parseAuthorizedKeys(location + "/authorized-keys", value["authorized-keys"], errors);
	}

	function parsePasswordAuthentication(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "password-authentication")) {
		obj.password_authentication = parsePasswordAuthentication(location + "/password-authentication", value["password-authentication"], errors);
	}
	else {
		obj.password_authentication = true;
	}

	return obj;
}

function instantiateServiceNtp(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseServers(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!matchUcHost(value))
				push(errors, [ location, "must be a valid hostname or IP address" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "servers")) {
		obj.servers = parseServers(location + "/servers", value["servers"], errors);
	}

	function parseLocalServer(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "local-server")) {
		obj.local_server = parseLocalServer(location + "/local-server", value["local-server"], errors);
	}

	return obj;
}

function instantiateServiceMdns(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseEnable(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "enable")) {
		obj.enable = parseEnable(location + "/enable", value["enable"], errors);
	}
	else {
		obj.enable = false;
	}

	return obj;
}

function instantiateServiceRtty(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseHost(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcHost(value))
			push(errors, [ location, "must be a valid hostname or IP address" ]);

		return value;
	}

	if (exists(value, "host")) {
		obj.host = parseHost(location + "/host", value["host"], errors);
	}

	function parsePort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		return value;
	}

	if (exists(value, "port")) {
		obj.port = parsePort(location + "/port", value["port"], errors);
	}
	else {
		obj.port = 5912;
	}

	function parseToken(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (length(value) > 32)
			push(errors, [ location, "must be at most 32 characters long" ]);

		if (length(value) < 32)
			push(errors, [ location, "must be at least 32 characters long" ]);

		return value;
	}

	if (exists(value, "token")) {
		obj.token = parseToken(location + "/token", value["token"], errors);
	}

	return obj;
}

function instantiateServiceLog(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseHost(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!matchUcHost(value))
			push(errors, [ location, "must be a valid hostname or IP address" ]);

		return value;
	}

	if (exists(value, "host")) {
		obj.host = parseHost(location + "/host", value["host"], errors);
	}

	function parsePort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 100)
			push(errors, [ location, "must be bigger than or equal to 100" ]);

		return value;
	}

	if (exists(value, "port")) {
		obj.port = parsePort(location + "/port", value["port"], errors);
	}

	function parseProto(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "tcp", "udp" ]))
			push(errors, [ location, "must be one of [ \"tcp\", \"udp\" ]" ]);

		return value;
	}

	if (exists(value, "proto")) {
		obj.proto = parseProto(location + "/proto", value["proto"], errors);
	}
	else {
		obj.proto = "udp";
	}

	function parseSize(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value < 32)
			push(errors, [ location, "must be bigger than or equal to 32" ]);

		return value;
	}

	if (exists(value, "size")) {
		obj.size = parseSize(location + "/size", value["size"], errors);
	}
	else {
		obj.size = 1000;
	}

	return obj;
}

function instantiateServiceHttp(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseHttpPort(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value > 65535)
			push(errors, [ location, "must be lower than or equal to 65535" ]);

		if (value < 1)
			push(errors, [ location, "must be bigger than or equal to 1" ]);

		return value;
	}

	if (exists(value, "http-port")) {
		obj.http_port = parseHttpPort(location + "/http-port", value["http-port"], errors);
	}
	else {
		obj.http_port = 80;
	}

	return obj;
}

function instantiateServiceIgmp(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseEnable(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "enable")) {
		obj.enable = parseEnable(location + "/enable", value["enable"], errors);
	}
	else {
		obj.enable = false;
	}

	return obj;
}

function instantiateServiceIeee8021x(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseEnable(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "enable")) {
		obj.enable = parseEnable(location + "/enable", value["enable"], errors);
	}
	else {
		obj.enable = false;
	}

	return obj;
}

function instantiateServiceWifiSteering(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseMode(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		if (!(value in [ "local", "cloud" ]))
			push(errors, [ location, "must be one of [ \"local\", \"cloud\" ]" ]);

		return value;
	}

	if (exists(value, "mode")) {
		obj.mode = parseMode(location + "/mode", value["mode"], errors);
	}

	function parseNetwork(location, value, errors) {
		if (type(value) != "string") {
			push(errors, [ location, "must be of type string" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "network")) {
		obj.network = parseNetwork(location + "/network", value["network"], errors);
	}
	else {
		obj.network = "upstream";
	}

	function parseAssocSteering(location, value, errors) {
		if (type(value) != "bool") {
			push(errors, [ location, "must be of type boolean" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "assoc-steering")) {
		obj.assoc_steering = parseAssocSteering(location + "/assoc-steering", value["assoc-steering"], errors);
	}
	else {
		obj.assoc_steering = false;
	}

	function parseRequiredSnr(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "required-snr")) {
		obj.required_snr = parseRequiredSnr(location + "/required-snr", value["required-snr"], errors);
	}
	else {
		obj.required_snr = 0;
	}

	function parseRequiredProbeSnr(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "required-probe-snr")) {
		obj.required_probe_snr = parseRequiredProbeSnr(location + "/required-probe-snr", value["required-probe-snr"], errors);
	}
	else {
		obj.required_probe_snr = 0;
	}

	function parseRequiredRoamSnr(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "required-roam-snr")) {
		obj.required_roam_snr = parseRequiredRoamSnr(location + "/required-roam-snr", value["required-roam-snr"], errors);
	}
	else {
		obj.required_roam_snr = 0;
	}

	function parseLoadKickThreshold(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "load-kick-threshold")) {
		obj.load_kick_threshold = parseLoadKickThreshold(location + "/load-kick-threshold", value["load-kick-threshold"], errors);
	}
	else {
		obj.load_kick_threshold = 0;
	}

	return obj;
}

function instantiateService(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	if (exists(value, "lldp")) {
		obj.lldp = instantiateServiceLldp(location + "/lldp", value["lldp"], errors);
	}

	if (exists(value, "ssh")) {
		obj.ssh = instantiateServiceSsh(location + "/ssh", value["ssh"], errors);
	}

	if (exists(value, "ntp")) {
		obj.ntp = instantiateServiceNtp(location + "/ntp", value["ntp"], errors);
	}

	if (exists(value, "mdns")) {
		obj.mdns = instantiateServiceMdns(location + "/mdns", value["mdns"], errors);
	}

	if (exists(value, "rtty")) {
		obj.rtty = instantiateServiceRtty(location + "/rtty", value["rtty"], errors);
	}

	if (exists(value, "log")) {
		obj.log = instantiateServiceLog(location + "/log", value["log"], errors);
	}

	if (exists(value, "http")) {
		obj.http = instantiateServiceHttp(location + "/http", value["http"], errors);
	}

	if (exists(value, "igmp")) {
		obj.igmp = instantiateServiceIgmp(location + "/igmp", value["igmp"], errors);
	}

	if (exists(value, "ieee8021x")) {
		obj.ieee8021x = instantiateServiceIeee8021x(location + "/ieee8021x", value["ieee8021x"], errors);
	}

	if (exists(value, "wifi-steering")) {
		obj.wifi_steering = instantiateServiceWifiSteering(location + "/wifi-steering", value["wifi-steering"], errors);
	}

	return obj;
}

function instantiateMetricsStatistics(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseInterval(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "interval")) {
		obj.interval = parseInterval(location + "/interval", value["interval"], errors);
	}

	function parseTypes(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!(value in [ "ssids", "lldp", "clients" ]))
				push(errors, [ location, "must be one of [ \"ssids\", \"lldp\", \"clients\" ]" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "types")) {
		obj.types = parseTypes(location + "/types", value["types"], errors);
	}

	return obj;
}

function instantiateMetricsHealth(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseInterval(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		if (value < 60)
			push(errors, [ location, "must be bigger than or equal to 60" ]);

		return value;
	}

	if (exists(value, "interval")) {
		obj.interval = parseInterval(location + "/interval", value["interval"], errors);
	}

	return obj;
}

function instantiateMetricsWifiFrames(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseFilters(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!(value in [ "probe", "auth", "assoc", "disassoc", "deauth", "local-deauth", "inactive-deauth", "key-mismatch", "beacon-report", "radar-detected" ]))
				push(errors, [ location, "must be one of [ \"probe\", \"auth\", \"assoc\", \"disassoc\", \"deauth\", \"local-deauth\", \"inactive-deauth\", \"key-mismatch\", \"beacon-report\", \"radar-detected\" ]" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "filters")) {
		obj.filters = parseFilters(location + "/filters", value["filters"], errors);
	}

	return obj;
}

function instantiateMetricsDhcpSnooping(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseFilters(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			if (!(value in [ "ack", "discover", "offer", "request", "solicit", "reply", "renew" ]))
				push(errors, [ location, "must be one of [ \"ack\", \"discover\", \"offer\", \"request\", \"solicit\", \"reply\", \"renew\" ]" ]);

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	if (exists(value, "filters")) {
		obj.filters = parseFilters(location + "/filters", value["filters"], errors);
	}

	return obj;
}

function instantiateMetrics(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	if (exists(value, "statistics")) {
		obj.statistics = instantiateMetricsStatistics(location + "/statistics", value["statistics"], errors);
	}

	if (exists(value, "health")) {
		obj.health = instantiateMetricsHealth(location + "/health", value["health"], errors);
	}

	if (exists(value, "wifi-frames")) {
		obj.wifi_frames = instantiateMetricsWifiFrames(location + "/wifi-frames", value["wifi-frames"], errors);
	}

	if (exists(value, "dhcp-snooping")) {
		obj.dhcp_snooping = instantiateMetricsDhcpSnooping(location + "/dhcp-snooping", value["dhcp-snooping"], errors);
	}

	return obj;
}

function instantiateConfigRaw(location, value, errors) {
	if (type(value) != "array") {
		push(errors, [ location, "must be of type array" ]);
		return null;
	}

	function parseItem(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		if (length(value) < 2)
			push(errors, [ location, "must have at least 2 items" ]);

		function parseItem(location, value, errors) {
			if (type(value) != "string") {
				push(errors, [ location, "must be of type string" ]);
				return null;
			}

			return value;
		}

		return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
	}

	return map(value, (item, i) => parseItem(location + "/" + i, item, errors));
}

function newUCentralState(location, value, errors) {
	if (type(value) != "object") {
		push(errors, [ location, "must be of type object" ]);
		return null;
	}

	let obj = {};

	function parseUuid(location, value, errors) {
		if (type(value) != "int") {
			push(errors, [ location, "must be of type integer" ]);
			return null;
		}

		return value;
	}

	if (exists(value, "uuid")) {
		obj.uuid = parseUuid(location + "/uuid", value["uuid"], errors);
	}

	if (exists(value, "unit")) {
		obj.unit = instantiateUnit(location + "/unit", value["unit"], errors);
	}

	if (exists(value, "globals")) {
		obj.globals = instantiateGlobals(location + "/globals", value["globals"], errors);
	}

	if (exists(value, "definitions")) {
		obj.definitions = instantiateDefinitions(location + "/definitions", value["definitions"], errors);
	}

	function parseRadios(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateRadio(location + "/" + i, item, errors));
	}

	if (exists(value, "radios")) {
		obj.radios = parseRadios(location + "/radios", value["radios"], errors);
	}

	function parseInterfaces(location, value, errors) {
		if (type(value) != "array") {
			push(errors, [ location, "must be of type array" ]);
			return null;
		}

		return map(value, (item, i) => instantiateInterface(location + "/" + i, item, errors));
	}

	if (exists(value, "interfaces")) {
		obj.interfaces = parseInterfaces(location + "/interfaces", value["interfaces"], errors);
	}

	if (exists(value, "services")) {
		obj.services = instantiateService(location + "/services", value["services"], errors);
	}

	if (exists(value, "metrics")) {
		obj.metrics = instantiateMetrics(location + "/metrics", value["metrics"], errors);
	}

	if (exists(value, "config-raw")) {
		obj.config_raw = instantiateConfigRaw(location + "/config-raw", value["config-raw"], errors);
	}

	return obj;
}

return {
	validate: (value, errors) => {
		let err = [];
		let res = newUCentralState("", value, err);
		if (errors) push(errors, ...map(err, e => "[E] (In " + e[0] + ") Value " + e[1]));
		return length(err) ? null : res;
	}
};

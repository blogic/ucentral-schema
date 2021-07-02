{%
/* find and replace the first upstream interface using vid with
 * the broadband settings */
let uplink = ethernet.get_interface("upstream", 0);
if (!uplink)
	return;

if (index([ "wwan", "pppoe" ], broadband.protocol) < 0)
	return;

for (let k, v in uplink)
	if (index([ "vlan", "index" ], k) < 0)
		delete uplink[k];

uplink.name = "ISP_UPLINK";
uplink.role = "upstream";
uplink.vlan = {	id: 0 };
uplink.metric = 1;

if (broadband.protocol == "wwan" && index([ "qmi", "mbim", "wwan" ], broadband['modem-type']) >= 0) {
	let wwan = { };

	wwan.protocol = 'wwan';
	wwan.modem_type = broadband['modem-type'];
	wwan.pin_code = broadband['pin-code'] || '';
	wwan.access_point_name = broadband['access-point-name'] || '';
	wwan.packet_data_protocol = broadband['packet-data-protocol'] || 'dual';
	wwan.authentication_type = broadband['authentication-type'] || 'none';
	wwan.username = broadband.username || '';
	wwan.password = broadband.password || '';

	uplink.broad_band = wwan;
}

if (broadband.protocol == "pppoe") {
	let pppoe = { };

	pppoe.protocol = 'pppoe';
	pppoe.username = broadband.username || '';
	pppoe.password = broadband.password || '';
	pppoe.timeout = broadband.timeout || '30';

	uplink.broad_band = pppoe;
	uplink.ethernet = [
		{
			"select_ports": [ "WAN*" ]
		}
	];
}

%}

{%

function generate_ssid(wifi, radio, ssid, name) {
	local name = radio + "_" + ssid.name;

	wifi[name] = {".type": "wifi-iface", "device": radio };
	for (local key in ssid.cfg):
		local val = ssid.cfg[key];
		wifi[name][key] = val;
	endfor
}

function generate_phy(wifi, x) {
	for (local phy in cfg.phy):
		if (phy.band in x.band === false)
			continue;
	
		wifi[x.uci] = {};
		for (local key in phy.cfg):
			local val = phy.cfg[key];

			wifi[x.uci][key] = val;
		endfor

		for (local ssid in cfg.ssid):
			for (local band in ssid.band):
				if (band != phy.band)
					continue;
				generate_ssid(wifi, x.uci, ssid);
			endfor
		endfor
		return true;
	endfor
	return false;
}

function generate_wifi() {
	local wifi= {};

	if (!capab.wifi)
		return;

	cursor = uci.cursor();
	cursor.load("wireless");
	cursor.foreach("wireless", "wifi-device", function(d) {
		if (!capab.wifi[d.path])
			continue;
		capab.wifi[d.path]["uci"] = d[".name"];
	});

	for (local path in capab.wifi):
		local phy = capab.wifi[path];

		if (generate_phy(wifi, phy) === false):
			wifi[phy.uci] = {"disabled": "1"};
		endif
	endfor
	render_uci("wireless", wifi);
}

generate_wifi();
%}

{%	fd = fs.open("wifi-phy.cfg");
	phys = json(fd.read("all"));
	fd = fs.open("wifi-ssid.cfg");
	ssids = json(fd.read("all"));

	for (local phy in phys.phy):
		for (local key in phy.cfg):
			local val = phy.cfg[key];

-%}set wireless.{{ phy.name }}.{{ key }}='{{ val }}'
{%		endfor
		print("\n");

		for (local ssid in ssids.ssid):
			for (local band in ssid.band):
				if (band != phy.band)
					continue;
				local iface = phy.name + "_" + ssid.name;
-%}set wireless.{{ iface }}=wifi-iface
{%				for (local key in ssid.cfg):
					local val = ssid.cfg[key];

-%}set wireless.{{ iface }}.{{ key }}='{{ val }}'
{%				endfor
			print("\n");
			endfor
		endfor
	endfor
%}

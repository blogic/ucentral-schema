{%
function uci_defaults(o, d) {
	for (local k, v in d)
		if (!o[k])
			o[k] = v;
}

function uci_requires(o, d) {
	for (local k, v in d)
		if (!o[v])
			return false;
	return true;
}

function uci_render(file, obj) {
	for (local sname in obj):
		local section = obj[sname];

		if (section[".type"]):
-%}set {{file}}.{{ sname }}={{ section[".type"] }}
{%		endif
		for (local oname in section):
			if (oname == ".type")
				continue;
			local option = section[oname];
			if (type(option) == "array"):
-%}del {{file}}.{{ sname }}.{{ oname }}
{%
			for (local k, v in option):
-%}add_list {{file}}.{{ sname }}.{{ oname }}='{{ v }}'
{%
			endfor
		else
-%}set {{file}}.{{ sname }}.{{ oname }}='{{ option }}'
{%
		endif
		endfor
	endfor
}

function uci_new_section(x, name, type, vals) {
	x[name] = { ".type": type };

	if (vals)
		for(local k,v in vals)
			x[name][k] = v;

	return x[name];
}

function uci_set_option(obj, cfg, key) {
	if (exists(cfg, key))
		obj[key] = cfg[key];
}

function uci_set_options(obj, cfg, key) {
	for (local k, v in key)
		uci_set_option(obj, cfg, v);
}

fails = {};
failed = false;

for (key in cfg) {
	if (key in ["uuid", "ssid"])
		continue;
	try {
		include(sprintf("cfg_%s.uc", key));
	} catch (e) {
		failed = true;
		fails[key] = e;
		warn("Exception while generating " + key + ": " + e + "\n");
	}
}

if (failed) {
	ctx = ubus.connect();
	ctx.call("ucentral", "log", {"error": "failed to apply config", "data": fails});
	ctx.disconnect();
	exit(1);
}

%}

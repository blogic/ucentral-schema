{%
	state = {};
	state.uuid = time();
	state.cfg_uuid = cfg.uuid;
	ctx = ubus.connect();
	state.system = ctx.call("system", "info");
	wifi = ctx.call("wifi", "iface");
	if (length(wifi))
		state["wifi-iface"] = wifi;
	wifi = ctx.call("wifi", "station");
	if (length(wifi))
		state["wifi-station"] = wifi;
	poe = ctx.call("poe", "info");
	if (length(poe))
		state.poe = poe;
	print(state);
%}

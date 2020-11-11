{%
	state = {};
	state.cfg_uuid = cfg.uuid;
	ctx = ubus.connect();
	state.system = ctx.call("system", "info");
	state["wifi-iface"] = ctx.call("wifi", "iface");
	state["wifi-station"] = ctx.call("wifi", "station");
	print(state);
%}

{%
	state = {};
	ctx = ubus.connect();
	state.system = ctx.call("system", "info");
	state.wifi = ctx.call("wifi", "station");
	print(state);
%}

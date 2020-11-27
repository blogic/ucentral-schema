{%
	ctx = ubus.connect();
	ctx.call("system", "reboot");
%}

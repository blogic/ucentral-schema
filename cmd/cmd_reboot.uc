{%
	ctx = ubus.connect();
	ctx.call("ucentral", "log", {"msg": "rebooting"});
	ctx.call("system", "reboot");
%}

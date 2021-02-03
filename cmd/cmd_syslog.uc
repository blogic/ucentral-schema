{%
ctx = ubus.connect();
if (!cmd.lines)
	cmd.lines = 100;

log = ctx.call("log", "read",  {"lines": cmd.lines, "oneshot": true, "stream": false});

ctx.call("ucentral", "send", log);
%}

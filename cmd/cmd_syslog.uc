{%
	let log_data = ctx.call("log", "read", {
		lines: +args.lines || 100,
		oneshot: true,
		stream: false
	});

	if (!log_data) {
		log("Unable to obtain system log contents: %s", ubus.error());

		return;
	}

	ctx.call("ucentral", "send", log_data);
%}

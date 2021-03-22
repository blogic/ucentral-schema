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

	result({
		"error": 0,
		"text": "Success",
		"resultCode": 0,
		"resultData": log_data
	});
%}

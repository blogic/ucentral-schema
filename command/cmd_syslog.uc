let log_data = ctx.call("log", "read", {
	lines: +args.lines || 100,
	oneshot: true,
	stream: false
});

if (!log_data || !log_data.log) {
	result(2, "Unable to obtain system log contents: %s", ubus.error());

	return;
}

warn(sprintf("Read %d lines\n", length(log_data.log)));

result_json({
	"error": 0,
	"text": "Success",
	"resultCode": 0,
	"resultData": log_data
});

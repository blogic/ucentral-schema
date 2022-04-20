let rc = system(args.command);

if (rc != 0) {
	result_json({
		"error": 2,
		"text": "Command returned an error",
		"resultCode": rc
	});

	return;
}
result_json({
	"error": 0,
	"text": "Command was executed"
});

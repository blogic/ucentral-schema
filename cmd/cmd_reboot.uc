{%
	log("Initiating reboot");

	ctx.call("system", "reboot");

	let err = ubus.error();

	if (err != null)
		result({
			"error": 2,
			"text": sprintf("Reboot call failed with status %s", err)
		});
%}

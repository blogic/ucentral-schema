{%
	log("Initiating reboot");

	ctx.call("system", "reboot");

	let err = ubus.error();

	if (err != null)
		result(2, "Reboot call failed with status %s", err);
%}

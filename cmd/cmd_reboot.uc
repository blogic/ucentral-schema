{%
	log("Initiating reboot");

	ctx.call("system", "reboot");

	let err = ubus.error();

	if (err != null)
		log("Reboot call failed with status %s", err);
%}

{%
	log("Initiating reboot");

	ctx.call("system", "reboot");

	let err = ctx.error();

	if (err != null)
		result(2, "Reboot call failed with status %s", err);
%}

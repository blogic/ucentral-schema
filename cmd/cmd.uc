{%

let ctx = ubus.connect();

if (!ctx) {
	warn("Unable to connect to ubus: " + ubus.error() + "\n");
	exit(1);
}

/* Convenience logger outputting to both stderr and remote central log */
function log(fmt, ...args) {
	let msg = sprintf(fmt, ...args);

	warn(msg + "\n");

	ctx.call("ucentral", "log", { msg: msg });
}

/* Scope of functions and ressources the command includes have access to */
let scope = {
	/* ressources */
	cursor: uci.cursor(),
	ctx,

	/* log helper */
	log,

	/* command argument object */
	args: cmd
}

if (match(cmd.cmd, /^[A-Za-z0-9_]+$/)) {
	try {
		include(sprintf("cmd_%s.uc", cmd.cmd), scope);
	}
	catch (e) {
		log("Exception invoking '%s' command module: %s", cmd.cmd, e);
	}
}
else {
	log("Invalid command module name specified");
}

%}

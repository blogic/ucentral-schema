{%
// UCI batch output master template

"use strict";

let uci = require("uci");
let ubus = require("ubus");
let fs = require("fs");

let cursor = uci ? uci.cursor() : null;
let conn = ubus ? ubus.connect() : null;

let capabfile = fs.open("/etc/ucentral/capabilities.json", "r");
let capab = capabfile ? json(capabfile.read("all")) : null;

assert(cursor, "Unable to instantiate uci");
assert(conn, "Unable to connect to ubus");
assert(capab, "Unable to load capabilities");

let topdir = sourcepath(0, true);

// Formats a given input value as uci boolean value.
function b(val) {
	return val ? '1' : '0';
}

// Formats a given input value as single quoted string, honouring uci
// specific escaping semantics.
function s(str) {
	if (str === null || str === '')
		return '';

	return sprintf("'%s'", replace(str, /'/g, "'\\''"));
}

// Attempts to include a file, catching potential exceptions
function tryinclude(path, scope) {
	if (!match(path, /^[A-Za-z0-9_\/-]+\.uc$/)) {
		warn("Refusing to handle invalid include path '%s'", path);
		return;
	}

	let parent_path = sourcepath(1, true);

	assert(parent_path, "Unable to determine calling template path");

	try {
		include(parent_path + "/" + path, scope);
	}
	catch (e) {
		warn("Unable to include path '%s': %s\n%s", path, e, e.stacktrace[0].context);
	}
}

let wiphy = render("ucentral.renderer.wiphy");
let ethernet = render("ucentral.renderer.ethernet");
let ipcalc = render("ucentral.renderer.ipcalc");
let services = render("ucentral.renderer.services");
let dhcp_relay = render("ucentral.renderer.dhcp_relay");
let local_profile = render("ucentral.renderer.profile");
let files = render("ucentral.renderer.files");

return {
	render: function(state, logs) {
		logs = logs || [];

		return render('templates/toplevel.uc', {
			location: '/',
			tryinclude,
			state,
			cursor,
			capab,
			
			wiphy,
			ethernet,
			ipcalc,
			services,
			dhcp_relay,
			local_profile,
			files,

			warn: (fmt, ...args) => push(logs, sprintf("[W] (In %s) ", location || '/') + sprintf(fmt, ...args)),
			info: (fmt, ...args) => push(logs, sprintf("[!] (In %s) ", location || '/') + sprintf(fmt, ...args)),

			b,
			s,
		});
	},

	write_files: function(logs) {
		logs = logs || [];

		files.purge(logs);

		return files.write(logs);
	},

	files_state: function() {
		return files.files;
	},

	services_state: function() {
		return services.state;
	}
};

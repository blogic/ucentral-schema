#!/usr/bin/ucode
{%
push(REQUIRE_SEARCH_PATH,
	"/usr/lib/ucode/*.so",
	"/usr/share/ucentral/*.uc");

let schemareader = require("schemareader");
let renderer = require("renderer");
let fs = require("fs");

let inputfile = fs.open(ARGV[2], "r");
let inputjson = json(inputfile.read("all"));

let error = 0;

inputfile.close();
let logs = [];

try {
	let batch = renderer.render(schemareader.validate(inputjson), logs);

	fs.stdout.write("Log messages:\n" + join("\n", logs) + "\n\n");

	fs.stdout.write("UCI batch output:\n" + batch + "\n");

	let outputjson = fs.open("/tmp/ucentral.uci", "w");
	outputjson.write(batch);
	outputjson.close();

	for (let cmd in [ 'rm -rf /tmp/config-shadow',
			  'cp -r /etc/config-shadow /tmp' ])
		system(cmd);

	let apply = fs.popen("/sbin/uci -c /tmp/config-shadow batch", "w");
	apply.write(batch);
	apply.close();

	for (let cmd in [ 'uci -c /tmp/config-shadow commit',
			  'cp /tmp/config-shadow/* /etc/config/',
			  'rm -rf /tmp/config-shadow',
			  'reload_config'])
		system(cmd);

	fs.unlink('/etc/ucentral/ucentral.active');
	fs.symlink(ARGV[2], '/etc/ucentral/ucentral.active');

}
catch (e) {
	error = 1;
	warn("Fatal error while generating UCI: ", e, "\n", e.stacktrace[0].context, "\n");
}

let ubus = require("ubus").connect();

ubus.call("ucentral", "result", {
	uuid: inputjson.uuid || 0,
	id: +ARGV[3] || 0,
	status: {
		error,
		text: error ? "Failed" : "Success",
		rejected: logs || []
	}
});
%}

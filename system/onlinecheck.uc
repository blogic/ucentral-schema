#!/usr/bin/ucode
let fs = require("fs");
let uci = require("uci");
let cursor = uci.cursor();

cursor.load("onlinecheck");
let config = cursor.get_all("onlinecheck", "@config[-1]");

let state_file = fs.open("/tmp/onlinecheck.state", "r");
let state = state_file ? json(state_file.read("all")) : {
	online: true,
	threshold: 0,
};
if (state_file)
	state_file.close();

let online_count = 0;
let online_success = 0;

for (let host in config.ping_hosts) {
	printf("ping %s\n", host);
	online_count++;

	let result = system("ping -c 1 -w 3 " + host);

	if (!result)
		online_success++;
}

for (let host in config.download_hosts) {
	printf("download %s\n", host);
	online_count++;

	let result = system(sprintf("/usr/bin/curl -m 3 http://%s/online.txt -o /tmp/onlinecheck.tmp", host));

	printf("result %d\n", result);

	if (result)
		continue;
	let online_file = fs.open("/tmp/onlinecheck.tmp");
	let ok = online_file.read("all") || '';
	online_file.close();
	if (split(ok, '\n')[0] == 'ok')
		online_success++;
}

printf("%d/%d checks have passed\n", online_success, online_count);

if (!online_success)
	state.threshold = state.threshold + 1;
else
	state.threshold = 0;

if (state.threshold >= config.check_threshold && state.online) {
	if (index(config.action, "wifi") >= 0)
		system("wifi down");
	if (index(config.action, "leds") >= 0)
		system("/etc/init.d/led blink");

	state.online = false;
	system("logger onlinecheck: going offline\n")

} else if (!state.threshold && !state.online) {
	if (index(config.action, "wifi") >= 0)
		system("wifi up");
	if (index(config.action, "leds") >= 0)
		system("/etc/init.d/led turnon");
	state.online = true;
	system("logger onlinecheck: going online\n")
}

let state_file = fs.open("/tmp/onlinecheck.state", "w");
state_file.write(state);
state_file.close();



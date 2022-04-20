let fs = require("fs");
let ubus = require("ubus");
let ctx = ubus.connect();
let services = ctx.call("service", "list");
let sysinfo = {};

for (let name, service in services) {
	if (!service.instances)
		continue;
	let s = [];
	for (let idx, instance in service.instances) {
		if (!instance.running)
			continue;
		push(s, {
			pid: instance.pid,
			basename: fs.basename(instance.command[0]),
			meminfo: instance.meminfo,
			load: instance.load,
			age: instance.age,
			fds: instance.fds,
		});
	}
	if (length(s))
		sysinfo[name] = s;
}
printf("%.J\n", sysinfo);

{%
let verbose = args.verbose ? true : false;
let active = args.active ? true : false;
ctx.call("wifi", "scan", { active });
system("sleep 5");
let scan = ctx.call("wifi", "scan_dump", {verbose});
result_json({
	"error": 0,
	"text": "Success",
	"resultCode": 1,
	scan: scan.scan
});
%}

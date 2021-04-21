{%
let verbose = args.verbose ? true : false;
if (args.bands) {
	for (let band in args.bands)
		ctx.call("wifi", "scan", { band });
} else {
	ctx.call("wifi", "scan");
}
system("sleep 5");
let scan = ctx.call("wifi", "scan_dump", {verbose});
result_json({
	"error": 0,
	"text": "Success",
	"resultCode": 1,
	"scan": scan.scan
});
%}

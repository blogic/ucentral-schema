{%
let verbose = args.verbose ? true : false;
ctx.call("wifi", "scan");
system("sleep 5");
let scan = ctx.call("wifi", "scan_dump", {verbose});
let survey = ctx.call("wifi", "survey");
result_json({
	"error": 0,
	"text": "Success",
	"resultCode": 1,
	"scan": {
		scan: scan.scan,
		survey: survey.survey
	}
});
%}

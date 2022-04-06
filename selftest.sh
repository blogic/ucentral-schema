#!/usr/bin/env bash

./generate-reader.uc > schemareader.uc
if [ -n "$1" ]; then
	cp $1 input.json
else
	./generate-example.uc > input.json
fi
cat <<EOT | ucode -R -
	push(REQUIRE_SEARCH_PATH,
		"/usr/local/lib/ucode/*.so",
		"tests/lib/*.uc",
		"renderer/*.uc");

	let mocklib = require("mocklib");
	let fs = mocklib.require("fs");

	let schemareader = require("schemareader");
	let renderer = require("renderer");

	let inputfile = fs.open("./input.json", "r");
	let inputjson = json(inputfile.read("all"));

	inputfile.close();

	try {
		let logs = [];

		let state = schemareader.validate(inputjson, logs);
		let batch = state ? renderer.render(state, logs) : "";
		let files = state ? renderer.files_state() : {};

		fs.stdout.write("Log messages:\n" + join("\n", logs) + "\n\n");

		fs.stdout.write("UCI batch output:\n" + batch + "\n");

		fs.stdout.write("Files:\n\n");

		for (let path in sort(keys(files)))
			fs.stdout.write(" * " + path + "\n   --\n   " + replace(files[path], "\n", "\n   ") + "\n   --\n\n");
	}
	catch (e) {
		warn("Fatal error while generating UCI: ", e, "\n", e.stacktrace[0].context, "\n");
	}
EOT

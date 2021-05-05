#!/usr/bin/env bash

./generate-reader.uc > schemareader.uc
./generate-example.uc > input.json

ucode -s '{%
	push(REQUIRE_SEARCH_PATH,
		"/usr/local/lib/ucode/*.so",
		"./*.uc");

	let schemareader = require("schemareader");
	let fs = require("fs");

	let inputfile = fs.open("./input.json", "r");
	let inputjson = json(inputfile.read("all"));

	inputfile.close();

	printf("%.J\n", schemareader.validate(inputjson));
%}'

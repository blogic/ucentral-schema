#!/usr/bin/ucode
{%
push(REQUIRE_SEARCH_PATH,
	"/usr/lib/ucode/*.so",
	"/usr/share/ucentral/*.uc");

let ubus = require("ubus");
let fs = require("fs");

let boardfile = fs.open("/etc/board.json", "r");
let board = json(boardfile.read("all"));
boardfile.close();

capa = {};
ctx = ubus.connect();
capa.compatible = replace(board.model.id, ',', '_');
capa.model = board.model.name;
capa.network = board.network;

if (board.bridge && board.bridge.name == "switch")
	capa.platform = "switch";
if (board.switch)
	capa.switch = board.switch;
wifi = ctx.call("wifi", "phy");
if (length(wifi)) {
	capa.wifi = wifi;
	capa.platform = "ap";
}

capafile = fs.open("/etc/ucentral/capabilities.json", "w");
capafile.write(capa);
capafile.close();
%}

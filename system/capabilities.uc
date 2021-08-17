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
let wifi = ctx.call("wifi", "phy");
capa.compatible = replace(board.model.id, ',', '_');
capa.model = board.model.name;

if (board.bridge && board.bridge.name == "switch")
	capa.platform = "switch";
else if (length(wifi))
	capa.platform = "ap";
else
	capa.platform = "unknown";

capa.network = {};
for (let k, v in board.network) {
	if (v.ports)
		capa.network[k] = v.ports;
	if (v.device)
		capa.network[k] = [v.device];
	if (v.ifname)
		capa.network[k] = split(replace(v.ifname, /^ */, ''), " ");
}

if (board.switch)
	capa.switch = board.switch;
if (length(wifi))
	capa.wifi = wifi;

capafile = fs.open("/etc/ucentral/capabilities.json", "w");
capafile.write(capa);
capafile.close();
%}

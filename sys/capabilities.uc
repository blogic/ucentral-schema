{%
	capa = {};
	ctx = ubus.connect();
	capa.compatible = replace(board.model.id, ',', '_');
	capa.model = board.model.name;
	capa.network = board.network;
	if (board["bridge"])
		capa["bridge-vlan"] = true;
	if (board["switch"])
		capa["switch"] = board["switch"];
	wifi = ctx.call("wifi", "phy");
	if (length(wifi))
		capa.wifi = wifi;
	print(capa);
%}

{%
	capa = {};
	ctx = ubus.connect();
	capa.model = board.model;
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

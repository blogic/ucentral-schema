{%
	capa = {};
	ctx = ubus.connect();
	capa.network = board.network;
	capa["switch"] = board["switch"];
	capa.wifi = ctx.call("wifi", "phy");
	print(capa);
%}

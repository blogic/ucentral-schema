{%
	capa = {};
	ctx = ubus.connect();
	capa.model = board.model;
	capa.network = board.network;
	capa["switch"] = board["switch"];
	capa.wifi = ctx.call("wifi", "phy");
	print(capa);
%}

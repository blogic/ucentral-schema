{%
if (!services.is_present("radius-gw-proxy"))
	return;
let ssids = services.lookup_ssids("radius-gw-proxy");
let enable = length(ssids);
services.set_enabled("radius-gw-proxy", enable);
%}

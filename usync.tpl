{%
function render_uci(file, obj) {
	for (local sname in obj):
		local section = obj[sname];

		if (section[".type"]):
-%}set {{file}}.{{ sname }}={{ section[".type"] }}
{%		endif
		for (local oname in section):
			if (oname == ".type")
				continue;
			local option = section[oname];
-%}set {{file}}.{{ sname }}.{{ oname }}='{{ option }}'
{%		endfor
	endfor
}

include("wifi.tpl")
%}

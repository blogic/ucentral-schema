{% if (!services.is_present("radsecproxy")) return %}
{% let enable = length(radius_proxy) %}
{% services.set_enabled("radsecproxy", enable) %}
{% if (!enable) return %}
{%
	if (!radius_proxy.host || !radius_proxy.port || !radius_proxy.secret) {
		warn("Can't start radius-proxy due to missing settings.");
		services.set_enabled("radsecproxy", false);
		return;
	}
%}

add radsecproxy options
add_list radsecproxy.@options[-1].ListenUDP='localhost:1812'
add_list radsecproxy.@options[-1].ListenUDP='localhost:1813'

add radsecproxy client
set radsecproxy.@client[-1].name='client'
set radsecproxy.@client[-1].host='localhost'
set radsecproxy.@client[-1].type='udp'
set radsecproxy.@client[-1].secret='secret'

add radsecproxy tls
set radsecproxy.@tls[-1].name='tls'
set radsecproxy.@tls[-1].CACertificateFile='/etc/ucentral/cas.pem'
set radsecproxy.@tls[-1].certificateFile='/etc/ucentral/cert.pem'
set radsecproxy.@tls[-1].certificateKeyFile='/etc/ucentral/key.pem'
set radsecproxy.@tls[-1].certificateKeyPassword=''

add radsecproxy server
set radsecproxy.@server[-1].name='server'
set radsecproxy.@server[-1].host={{ s(radius_proxy.host) }}
set radsecproxy.@server[-1].port='{{ radius_proxy.port }}'
set radsecproxy.@server[-1].secret={{ s(radius_proxy.secret) }}
set radsecproxy.@server[-1].type='tls'
set radsecproxy.@server[-1].tls='tls'
set radsecproxy.@server[-1].statusServer='0'
set radsecproxy.@server[-1].certificateNameCheck='0'

add radsecproxy realm
set radsecproxy.@realm[-1].name='*'
set radsecproxy.@realm[-1].server='server'
set radsecproxy.@realm[-1].accountingServer='server'

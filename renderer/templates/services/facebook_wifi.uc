{% if (!services.is_present("fbwifi")) return %}
{% let interfaces = services.lookup_interfaces("facebook-wifi") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("fbwifi", enable) %}
{% if (!enable) return %}

# Facebook-wifi service configuration

set fbwifi.main.enabled=1
set fbwifi.main.zone={{ s(ethernet.calculate_name(interfaces[0])) }}
set fbwifi.main.gateway_token='FBWIFI:GATEWAY|{{ facebook_wifi.vendor_id }}|{{ facebook_wifi.gateway_id }}|{{ facebook_wifi.secret }}'

set uhttpd.main=uhttpd
add_list uhttpd.main.listen_http='0.0.0.0:80'
add_list uhttpd.main.listen_http='[::]:80'
add_list uhttpd.main.listen_https='0.0.0.0:443'
add_list uhttpd.main.listen_https='[::]:443'
set uhttpd.main.redirect_https='0'
set uhttpd.main.home='/www'
set uhttpd.main.max_requests='3'
set uhttpd.main.max_connections='100'
set uhttpd.main.cgi_prefix='/cgi-bin'
add_list uhttpd.main.lua_prefix='/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua'
set uhttpd.main.script_timeout='60'
set uhttpd.main.network_timeout='30'
set uhttpd.main.http_keepalive='20'
set uhttpd.main.tcp_keepalive='1'
set uhttpd.main.cert='/tmp/fbwifi/https_server_cert'
set uhttpd.main.key='/tmp/fbwifi/https_server_key'
set uhttpd.main.json_script='/usr/share/fbwifi/uhttpd.json'
set uhttpd.main.rfc1918_filter='0'

set firewall.fbwifi=include
set firewall.fbwifi.enabled=1
set firewall.fbwifi.family=ipv4
set firewall.fbwifi.path=/usr/share/fbwifi/firewall.include
set firewall.fbwifi.reload=1
set firewall.fbwifi.type=script

set uhttpd.fbwifi_redirect=uhttpd
set uhttpd.fbwifi_redirect.enabled=1
set uhttpd.fbwifi_redirect.listen_http='0.0.0.0:2060'
set uhttpd.fbwifi_redirect.listen_https='0.0.0.0:2061'
set uhttpd.fbwifi_redirect.cert='/tmp/fbwifi/https_server_cert'
set uhttpd.fbwifi_redirect.key='/tmp/fbwifi/https_server_key'
set uhttpd.fbwifi_redirect.json_script='/tmp/fbwifi/uhttpd-redirect.json'

add_list dhcp.@dnsmasq[0].rebind_domain=fbwifigateway.net

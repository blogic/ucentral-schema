{%
let enable = true;
if (!services.is_present("onlinecheck") ||
    !length(online_check) ||
    (!length(online_check.ping_hosts) &&
     !length(online_check.download_hosts)))
	enable = false;

services.set_enabled("onlinecheck", enable);
if (!enable)
	return;
%}


# Online check service configuration
add onlinecheck config
set onlinecheck.@config[-1].check_interval={{ s(online_check.check_interval) }}
set onlinecheck.@config[-1].check_threshold={{ s(online_check.check_threshold) }}
{% for (let action in online_check.action): %}
add_list onlinecheck.@config[-1].action={{ s(action) }}
{% endfor %}
{% for (let host in online_check.ping_hosts): %}
add_list onlinecheck.@config[-1].ping_hosts={{ s(host) }}
{% endfor %}
{% for (let host in online_check.download_hosts): %}
add_list onlinecheck.@config[-1].download_hosts={{ s(host) }}
{% endfor %}

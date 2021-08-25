{% if (!services.is_present("openvswitch")) return %}
{% let interfaces = services.lookup_interfaces("open-flow") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("openvswitch", enable) %}
{% if (!enable) return %}


# OpenFlow service configuration

set openvswitch.ovs.disabled=0

set openvswitch.ovs.disabled="0"
set openvswitch.ovs.ca={{ s(files.add_anonymous(location, 'ca', b64dec(open_flow.ca_certificate))) }}
set openvswitch.ovs.cert={{ s(files.add_anonymous(location, 'cert', b64dec(open_flow.ssl_certificate))) }}
set openvswitch.ovs.key={{ s(files.add_anonymous(location, 'key', b64dec(open_flow.private_key))) }}

delete openvswitch.@ovs_bridge[0]
add openvswitch ovs_bridge
set openvswitch.@ovs_bridge[-1].controller="ssl:{{ open_flow.controller }}"
set openvswitch.@ovs_bridge[-1].datapath_id="0x{{ serial }}"
set openvswitch.@ovs_bridge[-1].name="br-ovs"

add openvswitch ovs_port
set openvswitch.@ovs_port[-1].bridge="br-ovs"
set openvswitch.@ovs_port[-1].port="gw0"
set openvswitch.@ovs_port[-1].ofport="1"
set openvswitch.@ovs_port[-1].type="internal"

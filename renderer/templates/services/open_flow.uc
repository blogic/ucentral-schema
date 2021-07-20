{% if (!services.is_present("openvswitch")) return %}
{% let interfaces = services.lookup_interfaces("open-flow") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("openvswitch", enable) %}
{% if (!enable) return %}


# OpenFlow service configuration

set openvswitch.ovs.disabled=0

delete openvswitch.@ovs_bridge[0]
add openvswitch ovs_bridge
set openvswitch.@ovs_bridge[-1].controller="tcp:{{open_flow.controller }}"
set openvswitch.@ovs_bridge[-1].name="br-ovs"
add_list openvswitch.@ovs_bridge[-1].ports="gw0:internal"

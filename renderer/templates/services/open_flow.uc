{% if (!services.is_present("openvswitch")) return %}
{% let interfaces = services.lookup_interfaces("open-flow") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("openvswitch", enable) %}
{% if (!enable) return %}
{% if (open_flow.mode in ['pssl', 'ssl'] &&
       !(open_flow.ca_certificate &&
	 open_flow.private_key &&
	 open_flow.ssl_certificate)) {
		warn("mode requires SSL CA, certificate and private key");
		return;
	}
%}



# OpenFlow service configuration

set openvswitch.ovs.disabled="0"
set openvswitch.ovs.ca={{ s(files.add_anonymous(location, 'ca', b64dec(open_flow.ca_certificate))) }}
set openvswitch.ovs.cert={{ s(files.add_anonymous(location, 'cert', b64dec(open_flow.ssl_certificate))) }}
set openvswitch.ovs.key={{ s(files.add_anonymous(location, 'key', b64dec(open_flow.private_key))) }}

delete openvswitch.@ovs_bridge[0]
add openvswitch ovs_bridge
set openvswitch.@ovs_bridge[-1].controller="{{ open_flow.mode }}:{{ open_flow.controller }}:{{ open_flow.port }}"
{% if (length(open_flow.datapath_description)): %}
	set openvswitch.@ovs_bridge[-1].datapath_desc="{{ s(open_flow.datapath_description) }}"
{% endif %}
set openvswitch.@ovs_bridge[-1].datapath_id="0x{{ serial }}"
set openvswitch.@ovs_bridge[-1].drop_unknown_ports="1"
set openvswitch.@ovs_bridge[-1].name="br-ovs"

add openvswitch ovs_port
set openvswitch.@ovs_port[-1].bridge="br-ovs"
set openvswitch.@ovs_port[-1].ofport="1"
{% if (interfaces[0].role == "downstream"): %}
set openvswitch.@ovs_port[-1].port="gw0"
set openvswitch.@ovs_port[-1].type="internal"
{% else %}
set openvswitch.@ovs_port[-1].port="oflow_ovs"

add network device
set network.@device[-1].name="oflow_lbr"
set network.@device[-1].type="veth"
set network.@device[-1].peer_name="oflow_ovs"

set network.oflow_lbr="interface"
set network.oflow_lbr.device="oflow_lbr"
set network.oflow_lbr.proto="none"

set network.oflow_ovs="interface"
set network.oflow_ovs.device="oflow_ovs"
set network.oflow_ovs.proto="none"
{% endif %}

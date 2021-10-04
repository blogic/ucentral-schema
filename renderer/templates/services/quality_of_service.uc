{%
if (!quality_of_service)
	quality_of_service = {};
let egress = ethernet.lookup_by_select_ports([quality_of_service.select_port]);
let enable = length(egress);
services.set_enabled("sqm", enable);
if (!enable)
	return;

if (!quality_of_service.upload_rate || !quality_of_service.download_rate) {
	quality_of_service.download_rate = 0;
	quality_of_service.upload_rate = 0;
}

function get_speed(dev, speed) {
	if (!speed)
		speed = ethernet.get_speed(dev);
	return speed * 1000;
}

function dscp_map(dscp) {
	let map = { "CS1": 8, "CS2": 16, "CS3": 24, "CS4": 32, "CS5": 40, "CS6": 48, "CS7": 56 };
	return map[dscp] ? map[dscp] : 0;
}

%}

{% for (let dev in egress): %}
set sqm.{{ dev }}=queue
set sqm.@queue[-1].interface={{ s(dev) }}
set sqm.@queue[-1].download='{{ get_speed(dev, quality_of_service.upload_rate) }}'
set sqm.@queue[-1].upload='{{ get_speed(dev, quality_of_service.download_rate) }}'
set sqm.@queue[-1].auto_rate='{{ quality_of_service.download_rate ? 0 : 1 }}'
set sqm.@queue[-1].enabled='1'
set sqm.@queue[-1].verbosity='5'
set sqm.@queue[-1].qdisc_advanced='1'
set sqm.@queue[-1].egress_ecn='NOECN'
set sqm.@queue[-1].squash_dscp='0'
set sqm.@queue[-1].squash_ingress='0'
set sqm.@queue[-1].ingress_ecn='ECN'
set sqm.@queue[-1].debug_logging='1'
set sqm.@queue[-1].qdisc='fq_codel'
set sqm.@queue[-1].script='layer_cake.qos'
set sqm.@queue[-1].linklayer='ethernet'
set sqm.@queue[-1].overhead='44'
set sqm.@queue[-1].eqdisc_opts='diffserv4 no-split-gso'
set sqm.@queue[-1].iqdisc_opts='diffserv4 no-split-gso'
{% endfor %}

{% for (let class in quality_of_service.classifier): %}
{%   if (!length(class.ports) && !length(class.dns)) continue; %}
{%   let dscp = dscp_map(class.dscp); %}
add sqm classifier
set sqm.@classifier[-1].dscp={{ dscp }}
{%   for (let fqdn in class.dns): %}
add_list sqm.@classifier[-1].dns={{ s(fqdn) }}
{%   endfor %}
{%   for (let port in class.ports): %}
{%     if (!port.protocol || !port.port) continue; %}
add_list sqm.@classifier[-1].ports='{{ port.protocol }}:{{ port.port }}{{ port.range_end ? ":" + port.range_end : "" }}'
{%   endfor %}
{% endfor %}

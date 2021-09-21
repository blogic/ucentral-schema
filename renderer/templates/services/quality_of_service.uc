{%
if (!quality_of_service)
	quality_of_service = {};
let eth = services.lookup_ethernet("quality-of-service");
let egress = ethernet.lookup_by_ethernet(eth);
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

{% let egress = ethernet.lookup_by_select_ports([quality_of_service.select_port]) %}
{% let enable = length(egress) %}
{% services.set_enabled("sqm", enable) %}
{% if (!enable) return %}

add sqm queue
set sqm.@queue[-1].interface='{{ egress[0] }}'
set sqm.@queue[-1].download='{{quality_of_service.download_rate }}'
set sqm.@queue[-1].upload='{{quality_of_service.upload_rate }}'
set sqm.@queue[-1].enabled='1'
set sqm.@queue[-1].verbosity='5'
set sqm.@queue[-1].qdisc_advanced='1'
set sqm.@queue[-1].egress_ecn='NOECN'
set sqm.@queue[-1].squash_dscp='0'
set sqm.@queue[-1].squash_ingress='0'
set sqm.@queue[-1].ingress_ecn='ECN'
set sqm.@queue[-1].debug_logging='1'
set sqm.@queue[-1].qdisc='fq_codel'
set sqm.@queue[-1].linklayer='none'
set sqm.@queue[-1].script='layer_cake.qos'

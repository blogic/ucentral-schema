{% if (state.switch.port_mirror && state.switch.port_mirror.monitor_ports && state.switch.port_mirror.analysis_port): %}

# Switch  port-mirror configuration

set switch.mirror=port-mirror
{%   for (let port in state.switch.port_mirror.monitor_ports): %}
add_list switch.mirror.monitor={{ s(port) }}
{%   endfor %}
set switch.mirror.analysis={{ s(state.switch.port_mirror.analysis_port) }}
{% endif %}

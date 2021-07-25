# Data Plane service configuration
{%
let iface = {};

function render(dict, type) {
	for (let idx, filter in dict) {
%}
set dataplane.{{ filter.name }}=program
set dataplane.{{ filter.name }}.type={{ type }}
set dataplane.{{ filter.name }}.program={{ s(files.add_anonymous(location, 'ingress_' + idx, b64dec(filter.program))) }}
{%
		for (let i in services.lookup_interfaces("data-plane:" + filter.name)) {
			let name = ethernet.calculate_name(i);
			if (!length(iface[name]))
				iface[name] = [];
			push(iface[name], filter.name);
		}
	}
}

render(data_plane.ingress_filters, "ingress");
%}

{% for (let k, v in iface): %}
set dataplane.{{ k }}=interface
{%   for (let i, p in v): %}
add_list dataplane.{{ k }}.program={{ s(p) }}
{%   endfor %}
{% endfor %}

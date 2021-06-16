{% if (!services.is_present("ieee8021x")) return %}
{% let interfaces = services.lookup_interfaces("ieee8021x") %}
{% let enable = length(interfaces) %}
{% services.set_enabled("ieee8021x", enable) %}
{% if (!enable) return %}

# IEEE8021x service configuration

add ieee8021x certificates
{% if (ieee8021x.use_local_certificates): %}
{%   cursor.load("system") %}
{%   let certs = cursor.get_all("system", "@certificates[-1]") %}
set ieee8021x.@certificates[-1].ca={{ s(certs.ca) }}
set ieee8021x.@certificates[-1].cert={{ s(certs.cert) }}
set ieee8021x.@certificates[-1].key={{ s(certs.key) }}
{% else %}
set ieee8021x.@certificates[-1].ca={{ s(ieee8021x.ca_certificate) }}
set ieee8021x.@certificates[-1].cert={{ s(ieee8021x.server_certificate) }}
set ieee8021x.@certificates[-1].key={{ s(ieee8021x.private_key) }}
{% endif %}

{% for (let interface in interfaces): %}
{%   let name = ethernet.calculate_name(interface) %}
add ieee8021x network
set ieee8021x.@network[-1].network={{ name }}
{%  for (let port in ethernet.lookup_by_interface_spec(interface)): %}
add_list ieee8021x.@network[-1].ports={{ s(port) }}
{%  endfor %}
{%  for (let port in ethernet.lookup_by_interface_spec(interface)): %}

set network.{{ port }}=device
set network.@device[-1].name={{ s(port) }}
set network.@device[-1].auth='1'
{%  endfor %}
{% endfor %}
{% files.add_named("/var/run/hostapd-ieee8021x.eap_user", render("../eap_users.uc", { users: ieee8021x.users })) %}

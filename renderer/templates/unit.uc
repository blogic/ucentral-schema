
# Basic unit configuration
{% if (unit.name): %}
set system.@system[-1].description={{ s(unit.name) }}
{% endif %}
{% if (unit.location): %}
set system.@system[-1].notes={{ s(unit.location) }}
{% endif %}
{% if (unit.timezone): %}
set system.@system[-1].timezone={{ s(unit.timezone) }}
{% endif %}
set system.@system[-1].leds_off={{ b(!unit.leds_active) }}
{%
if (unit.random_password)
	shell.password();
%}

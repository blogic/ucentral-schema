
# Basic unit configuration
{% if (unit.name): %}
set system.description={{ s(unit.name) }}
{% endif %}
{% if (unit.location): %}
set system.notes={{ s(unit.location) }}
{% endif %}
{% if (unit.timezone): %}
set system.timezone={{ s(unit.timezone) }}
{% endif %}

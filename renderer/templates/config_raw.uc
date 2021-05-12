
# Raw Configuration
{% for (let config in config_raw): %}
{{ config[0] }} {{ config[1] }}{{config[2] ? '=' + config[2] : ''}}
{% endfor %}

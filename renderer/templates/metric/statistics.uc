{% if (!statistics) return %}

# Statistics configuration
set ustats.stats.interval={{ statistics.interval }}
{% for (let statistic in statistics.types): %}
add_list ustats.stats.types={{ statistic  }}
{% endfor %}

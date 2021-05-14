
# Statistics configuration
set ustats.stats.interval={{ statistics.interval }}
delete ustats.stats.types
{% for (let statistic in statistics.types): %}
add_list ustats.stats.types={{ statistic  }}
{% endfor %}

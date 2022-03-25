{%
	services.set_enabled("uhealth", true);
	if (!health)
		return;
%}

# Health configuration
set ustats.health.interval={{ health.interval }}

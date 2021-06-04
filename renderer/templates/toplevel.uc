{%
	// reject the config if there is no valid upstream configuration
	if (!state.uuid) {
		warn('Configuration must contain a valid UUID. Rejecting whole file');
		die('Configuration must contain a valid UUID. Rejecting whole file');
	}

	// reject the config if there is no valid upstream configuration
	let upstream;
	for (let i, interface in state.interfaces) {
		if (interface.role != 'upstream')
			continue;
		upstream = interface;
	}

	if (!upstream) {
		warn('Configuration must contain at least one valid upstream interface. Rejecting whole file');
		die('Configuration must contain at least one valid upstream interface. Rejecting whole file');
	}

	include('base.uc');

	if (state.unit)
		include('unit.uc', { location: '/unit', unit: state.unit });

	for (let service in services.lookup_services())
		tryinclude('services/' + service + '.uc', {
			location: '/services/' + service,
			[service]: state.services[service] || {}
		});

	for (let metric in services.lookup_metrics())
		tryinclude('metric/' + metric + '.uc', {
			location: '/metric/' + metric,
			[metric]: state.metrics[metric] || {}
		});

	for (let i, radio in state.radios)
		include('radio.uc', { location: '/radios/' + i, radio });

	let vlans = [];
	function iterate_interfaces(role) {
		for (let i, interface in state.interfaces) {
			if (interface.role != role)
				continue;
			include('interface.uc', { location: '/interfaces/' + i, interface, vlans });
		}
	}

	iterate_interfaces("upstream");
	iterate_interfaces("downstream");

	if (state.config_raw)
		include("config_raw.uc", { location: '/config_raw', config_raw: state.config_raw });
%}

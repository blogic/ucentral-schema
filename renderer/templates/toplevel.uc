{%
	include('unit.uc', { location: '/unit', unit: state.unit });

	for (let service in state.services)
		include('services/' + service + '.uc', {
			location: '/services/' + service,
			[service]: state.services[service]
		});

	for (let metric in state.metrics)
		include('metric/' + metric + '.uc', {
			location: '/metric/' + metric,
			[metric]: state.metrics[metric]
		});

	for (let i, radio in state.radios)
		include('radio.uc', { location: '/radios/' + i, radio });

	for (let i, interface in state.interfaces)
		include('interface.uc', { location: '/interfaces/' + i, interface });

	if (state.config_raw)
		include("config_raw.uc", { location: '/config_raw', config_raw: state.config_raw });
%}

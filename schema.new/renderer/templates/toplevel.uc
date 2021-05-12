{%
	include('unit.uc', { location: '/unit', unit: state.unit });

	for (let i, radio in state.radios)
		include('radio.uc', { location: '/radios/' + i, radio });

	for (let i, interface in state.interfaces)
		include('interface.uc', { location: '/interfaces/' + i, interface });
%}

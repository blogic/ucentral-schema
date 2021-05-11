{%
	include('unit.uc', { unit: state.unit });

	for (let radio in state.radios)
		include('radio.uc', { radio });

	for (let interface in state.interfaces)
		include('interface.uc', { interface });
%}

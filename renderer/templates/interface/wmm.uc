{%

let wmm = state?.globals?.wireless_multimedia;

if (!length(wmm))
	return;

let class = {
	"CS1": 8,
	"CS2": 16,
	"CS3": 24,
	"CS4": 32,
	"CS5": 40,
	"CS6": 48,
	"CS7": 56,
	"AF11": 10,
	"AF12": 12,
	"AF13": 14,
	"AF21": 18,
	"AF22": 20,
	"AF23": 22,
	"AF31": 26,
	"AF32": 28,
	"AF33": 30,
	"AF41": 34,
	"AF42": 36,
	"AF43": 38,
	"EF": 46,
	"DF": 0,
};

let profiles = {
	"enterprise": {
		"UP0": [ "DF"],
		"UP1": [ "CS1" ],
		"UP2": [ "AF11", "AF12", "AF13" ],
		"UP3": [ "CS2", "AF21", "AF22", "AF23" ],
		"UP4": [ "CS3", "AF31", "AF32", "AF33" ],
		"UP5": [ "CS5", "AF41", "AF42", "AF43" ],
		"UP6": [ "CS4", "EF" ],
		"UP7": [ "CS6" ]
	}
};

function qos_map() {
	let up_map = [];

	if (wmm.profile)
		wmm = profiles[wmm.profile];

	for (let prio = 0; prio < 8; prio++) {
		let up = wmm["UP" + prio];
		let len = length(up);

		if (length(up) < 2)
			continue;

		for (let idx = 1; idx < len; idx++) {
			push(up_map, class[up[idx]]);
			push(up_map, prio);
		}
	}

	for (let prio = 0; prio < 8; prio++) {
		let up = wmm["UP" + prio];

		if (length(up))
			push(up_map, class[up[0]]);
		else
			push(up_map, 255);
		push(up_map, 255);
	}
	let qos_map = join(",", up_map);

	return qos_map;
}
%}
set wireless.{{ section }}.iw_qos_map_set={{ s(qos_map()) }}

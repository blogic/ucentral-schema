let nl = require("nl80211");
let def = nl.const;
let rv = { survey: [] };
//let frequency = 5660;

function survey_get(dev) {
        let res = nl.request(def.NL80211_CMD_GET_SURVEY, def.NLM_F_DUMP, { dev });

        if (res === false)
                warn("Unable to lookup survey: " + nl.error() + "\n");

        return res;
}

function wif_get(wdev) {
	let res = nl.request(def.NL80211_CMD_GET_INTERFACE, def.NLM_F_DUMP);

	if (res === false)
		warn("Unable to lookup interfaces: " + nl.error() + "\n");

	return res;
}

function lookup_survey() {
	let wifs = wif_get();

	for (let wif in wifs)
		for (let survey in survey_get(wif.ifname))
			if (!frequency || survey.survey_info.frequency == frequency)
				if (survey.survey_info?.time)
					push(rv.survey, survey.survey_info);
}

lookup_survey();
//printf('%.J\n', rv);
return rv;

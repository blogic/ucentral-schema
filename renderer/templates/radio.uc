{%
	let phy = wiphy.lookup_by_band(radio.band);

	if (!phy) {
		warn("Can't find a suitable radio phy for band %s radio settings", radio.band);

		return;
	}

	function match_htmode(phy, channel_mode, channel_width) {
		let fallback_modes = { HE: /^(HE|VHT|HT)/, VHT: /^(VHT|HT)/, HT: /^HT/ };
		let mode_weight = { HT: 1, VHT: 10, HE: 100 };
		let wanted_mode = channel_mode + (channel_width == 8080 ? "80+80" : channel_width);

		let supported_phy_modes = map(sort(map(phy.htmode, (mode) => {
			let m = match(mode, /^([A-Z]+)(.+)$/);
			return [ mode, mode_weight[m[1]] * (m[2] == "80+80" ? 159 : +m[2]) ];
		}), (a, b) => (b[1] - a[1])), i => i[0]);

		if (wanted_mode in supported_phy_modes)
			return wanted_mode;

		for (let supported_mode in supported_phy_modes) {
			if (match(supported_mode, fallback_modes[channel_mode])) {
				warn("Selected radio does not support requested HT mode %s, falling back to %s",
					wanted_mode, supported_mode);

				return supported_mode;
			}
		}

		die("Selected radio does not support any HT modes");
	}

	function match_channel(phy, wanted_channel) {
		if (!wanted_channel || wanted_channel == "auto")
			return 0;

		if (wanted_channel in phy.channels)
			return wanted_channel;

		let min = (wanted_channel <= 14) ?  1 :  32;
		let max = (wanted_channel <= 14) ? 14 : 196;
		let eligible_channels = filter(phy.channels, (ch) => (ch >= min && ch <= max));

		// try to find a channel next to the wanted one
		for (let i = length(eligible_channels); i > 0; i--) {
			let candidate = eligible_channels[i - 1];

			if (candidate < wanted_channel || i == 1) {
				warn("Selected radio does not support requested channel %d, falling back to %d",
					wanted_channel, candidate);

				return candidate;
			}
		}

		warn("Selected radio does not support any channel in the target frequency range, falling back to %d",
			phy.channels[0]);

		return phy.channels[0];
	}

	function match_mimo(available_ant, wanted_mimo) {
		if (!radio.mimo)
			return available_ant;

		let shift = ((available_ant & 0xf0) == available_ant) ? 4 : 0;
		let m = match(wanted_mimo, /^([0-9]+)x([0-9]+$)/);
		if (!m) {
			warn("Failed to parse MIMO mode, falling back to %d", available_ant);

			return available_ant;
		}
		let use_ant = (m[1] * m[2] - 1) || 1;

		if (!use_ant || (use_ant << shift) > available_ant) {
			warn("Invalid or unsupported MIMO mode %s specified, falling back to %d",
				wanted_mimo || 'none', available_ant);

			return available_ant;
		}

		return use_ant << shift;
	}

	function match_require_mode(require_mode) {
		let modes = { HT: "n", VHT: "ac", HE: "ax" };

		return modes[require_mode] || '';
	}

	let htmode = match_htmode(phy, radio.channel_mode, radio.channel_width);
%}

# Wireless Configuration
set wireless.{{ phy.section }}.disabled=0
set wireless.{{ phy.section }}.htmode={{ htmode }}
{% if (radio.channel): %}
set wireless.{{ phy.section }}.channel={{ match_channel(phy, radio.channel) }}
{% endif %}
set wireless.{{ phy.section }}.txantenna={{ match_mimo(phy.tx_ant, radio.mimo) }}
set wireless.{{ phy.section }}.rxantenna={{ match_mimo(phy.rx_ant, radio.mimo) }}
set wireless.{{ phy.section }}.beacon_int={{ radio.beacon_interval }}
set wireless.{{ phy.section }}.dtim_period={{ radio.dtim_period }}
set wireless.{{ phy.section }}.country={{ s(radio.country) }}
set wireless.{{ phy.section }}.require_mode={{ s(match_require_mode(radio.require_mode)) }}
set wireless.{{ phy.section }}.txpower={{ radio.tx_power }}
set wireless.{{ phy.section }}.legacy_rates={{ b(radio.legacy_rates) }}
set wireless.{{ phy.section }}.chan_bw={{ radio.bandwidth }}
set wireless.{{ phy.section }}.maxassoc={{ radio.maximum_clients }}
{% if (radio.he_settings && phy.he_mac_capa && match(htmode, /HE.*/)): %}
set wireless.{{ phy.section }}.he_bss_color={{ radio.he_settings.bss_color }}
set wireless.{{ phy.section }}.multiple_bssid={{ b(radio.he_settings.multiple_bssid) }}
set wireless.{{ phy.section }}.ema={{ b(radio.he_settings.ema) }}
{% endif %}


{%

"use strict";

return {
	phys: conn.call("wifi", "phy"),

	band_freqs: {
		'2G':       [  2412,  2484 ],
		'5G':       [  5160,  5885 ],
		'5G-lower': [  5160,  5340 ],
		'5G-upper': [  5480,  5885 ],
		'6G':       [  5925,  7125 ],
		'60G':		[ 58320, 69120 ]
	},

	band_channels: {
		'2G': [ 1, 14 ],
		'5G': [ 7, 196 ],
		'5G-lower': [ 7, 68 ],
		'5G-upper': [ 96, 177 ],
		'6G': [ 200, 600 ], // FIXME
		'60G': [ 1, 6 ]
	},

	channel_to_freq: function(band, channel) {
		if (band == '2G' && channel >= 1 && channel <= 13)
			return 2407 + channel * 5;
		else if (band == '2G' && channel == 14)
			return 2484;
		else if (band == '5G' && channel >= 7 && channel <= 177)
			return 5000 + channel * 5;
		else if (band == '5G' && channel >= 183 && channel <= 196)
			return 4000 + channel * 5;
		else if (band == '60G' && channel >= 1 && channel <= 6)
			return 56160 + channel * 2160;

		return null;
	},

	path_to_section: function(path) {
		let sid = null;

		cursor.load("wireless");
		cursor.foreach("wireless", "wifi-device", (s) => {
			if (s.path == path) {
				sid = s['.name'];

				return false;
			}
		});

		return sid;
	},

	lookup_by_band: function(band) {
		let baseband = band;
		let phys = [];

		if (band in ['5G-lower', '5G-upper'])
			baseband = '5G';

		for (let path, phy in this.phys) {
			if (!(baseband in phy.band))
				continue;

			let phy_min_freq, phy_max_freq;

			if (phy.frequencies) {
				phy_min_freq = min(...phy.frequencies);
				phy_max_freq = max(...phy.frequencies);
			}
			else {
				/* NB: this code is superfluous once ubus call wifi phy reports
				       supported frequencies directly */

				let min_ch = max(min(...phy.channels), this.band_channels[band][0]),
				    max_ch = min(max(...phy.channels), this.band_channels[band][1]);

				phy_min_freq = this.channel_to_freq(baseband, min_ch);
				phy_max_freq = this.channel_to_freq(baseband, max_ch);

				if (phy_min_freq === null) {
					warn("Unable to map channel %d in band %s to frequency", min_ch, baseband);
					continue;
				}

				if (phy_max_freq === null) {
					warn("Unable to map channel %d in band %s to frequency", max_ch, baseband);
					continue;
				}
			}

			/* phy's frequency range does not overlap with band's frequency range, skip phy */
			if (phy_max_freq < this.band_freqs[band][0] || phy_min_freq > this.band_freqs[band][1])
				continue;

			let sid = this.path_to_section(path);

			if (sid)
				push(phys, { ...phy, section: sid });
		}

		return phys;
	},

	allocate_ssid_section_id: function(phy) {
		phy.networks = ++phy.networks || 1;

		assert(phy.section, "Radio has no related uci section");

		return phy.section + 'net' + phy.networks;
	}
};
%}

{%

"use local";

return {
	get: function() {
		let profile_file = fs.open("/etc/ucentral/profile.json");

		if (profile_file) {
			let profile = json(profile_file.read("all"));

			profile_file.close();

			return profile;
		}
		return null;
	}
};
%}

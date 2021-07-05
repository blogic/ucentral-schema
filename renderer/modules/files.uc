{%

"use strict";

return {
	files: {},
	basedir: '/tmp/ucentral',

	escape: function(s) {
		return replace(s, /[~\/]/g, m => (m == '~' ? '~0' : '~1'));
	},

	add_named: function(path, content) {
		if (index(path, '/') != 0)
			path = this.basedir + '/' + path;

		this.files[path] = content;
	},

	add_anonymous: function(location, name, content) {
		let path = this.basedir + '/' + this.escape(location) + '/' + this.escape(name);

		this.files[path] = content;

		return path;
	},

	purge: function(logs, dir) {
		if (dir == null)
			dir = this.basedir;

		let d = fs.opendir(dir);

		if (d) {
			let e;

			while ((e = d.read()) != null) {
				if (e == '.' || e == '..')
					continue;
				let p = dir + '/' + e,
				    s = fs.lstat(p);

				if (s == null)
					push(logs, sprintf("[W] Unable to lstat() path '%s': %s", p, fs.error()));
				else if (s.type == 'directory')
					this.purge(logs, p);
				else if (!fs.unlink(p))
					push(logs, sprintf("[W] Unable to unlink() path '%s': %s", p, fs.error()));
			}

			d.close();

			if (dir != this.basedir && !fs.rmdir(dir))
				push(logs, sprintf("[W] Unable to rmdir() path '%s': %s", dir, fs.error()));
		}
		else {
			push(logs, sprintf("[W] Unable to opendir() path '%s': %s", dir, fs.error()));
		}
	},

	mkdir_path: function(logs, path) {
		assert(index(path, '/') == 0, "Expecting absolute path");

		let segments = split(path, '/'),
		    tmppath = shift(segments);

		for (let i = 0; i < length(segments) - 1; i++) {
			tmppath += '/' + segments[i];

			let s = fs.stat(tmppath);

			if (s != null && s.type == 'directory')
				continue;

			if (fs.mkdir(tmppath))
				continue;

			push(logs, sprintf("[E] Unable to mkdir() path '%s': %s", tmppath, fs.error()));

			return false;
		}

		return true;
	},

	write: function(logs) {
		let success = true;

		for (let path, content in this.files) {
			if (!this.mkdir_path(logs, path)) {
				success = false;
				continue;
			}

			let f = fs.open(path, "w");

			if (f) {
				f.write(content);
				f.close();
			}
			else {
				push(logs, sprintf("[E] Unable to open() path '%s' for writing: %s", path, fs.error()));
				success = false;
			}
		}

		return success;
	}
};

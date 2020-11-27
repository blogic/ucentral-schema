{%
try {
	if (match(cmd.cmd, /^[A-Za-z0-9_]+$/))
		include(sprintf("cmd_%s.uc", cmd.cmd));
} catch (e) {
	warn("Exception while executing: " + cmd + "\n");
}
%}

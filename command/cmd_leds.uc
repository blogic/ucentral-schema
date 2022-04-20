function set_led(val, path)
{
	let cursor = uci.cursor(path);
	cursor.set("system", "@system[-1]", "leds_off", val);
	cursor.commit();
}

let val = 0;
if (args.pattern ==  "off")
	val = 1;

set_led(val);
set_led(val, "/etc/config-shadow/");

system("/etc/init.d/led restart");

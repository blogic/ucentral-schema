{%
	log("Initiating support dump");
	let serial = cursor.get("ucentral", "config", "serial");
	let support_dir = sprintf("support-%s-%s", args.serial, time());
	let support_tar = sprintf("/tmp/%s.tar.gz", support_dir);
	let mkdir_support_dir = sprintf("/bin/mkdir /tmp/%s", support_dir);
	system(mkdir_support_dir);
	for (let dir in ['command', 'fs', 'pcap', 'fs/tmp', 'fs/etc', 'fs/proc', 'fs/etc/ucentral']) {
		let mkdir_subdir = sprintf("/bin/mkdir /tmp/%s/%s", support_dir, dir);
		system(mkdir_subdir);
	};
	system(sprintf("/bin/cp /etc/ucentral/ucentral.cfg* /tmp/%s/fs/etc/ucentral", support_dir));
	system(sprintf("/bin/df > /tmp/%s/command/df", support_dir));
	system(sprintf("/bin/dmesg > /tmp/%s/command/dmesg", support_dir));
	system(sprintf("/bin/mount > /tmp/%s/command/mount", support_dir));
	system(sprintf("/bin/netstat -aln > /tmp/%s/command/netstat", support_dir));
	system(sprintf("/bin/ps > /tmp/%s/command/ps", support_dir));
	system(sprintf("/bin/ubus list hostapd.* | while read phy ; do ubus call $phy get_clients ; done > /tmp/%s/command/ubus_hostapd_clients", support_dir));
	system(sprintf("/sbin/ifconfig > /tmp/%s/command/ifconfig", support_dir));
	system(sprintf("/sbin/ip address show > /tmp/%s/command/ip_address", support_dir));
	system(sprintf("/sbin/ip link show > /tmp/%s/command/ip_link", support_dir));
	system(sprintf("/sbin/ip neigh show > /tmp/%s/command/ip_neigh", support_dir));
        system(sprintf("/sbin/ip route show > /tmp/%s/command/ip_route", support_dir));
	system(sprintf("/sbin/ip rule show > /tmp/%s/command/ip_rule", support_dir));
	system(sprintf("/sbin/logread > /tmp/%s/command/logread", support_dir));
	system(sprintf("/sbin/lsmod > /tmp/%s/command/lsmod", support_dir));
	system(sprintf("/sbin/uci show > /tmp/%s/command/uci_show", support_dir));
	system(sprintf("/sbin/wifi status > /tmp/%s/command/wifi_status", support_dir));
	system(sprintf("/usr/bin/free > /tmp/%s/command/free", support_dir));
	system(sprintf("/usr/bin/top -bn 1 > /tmp/%s/command/top", support_dir));
	system(sprintf("/usr/bin/uptime > /tmp/%s/command/uptime", support_dir));
	system(sprintf("/usr/sbin/bridge link show > /tmp/%s/command/bridge_link", support_dir));
	system(sprintf("/usr/sbin/bridge fdb show > /tmp/%s/command/bridge_fdb", support_dir));
	system(sprintf("/usr/sbin/bridge vlan show > /tmp/%s/command/bridge_vlan", support_dir));
	system(sprintf("/usr/sbin/iptables -L -v -n -t filter > /tmp/%s/command/iptables_filter", support_dir));
	system(sprintf("/usr/sbin/iptables -L -v -n -t mangle > /tmp/%s/command/iptables_mangle", support_dir));
	system(sprintf("/usr/sbin/iptables -L -v -n -t nat > /tmp/%s/command/iptables_nat", support_dir));
	system(sprintf("/usr/sbin/iw list > /tmp/%s/command/iw_list", support_dir));
	system(sprintf("/usr/sbin/qosify-status > /tmp/%s/command/qosify-status", support_dir));
	system(sprintf("/bin/cat /proc/loadavg > /tmp/%s/fs/proc/loadavg", support_dir));
	system(sprintf("/bin/cat /proc/vmstat > /tmp/%s/fs/proc/vmstat", support_dir));


	system(sprintf("/bin/tar -C /tmp/%s -czf %s ./", support_dir, support_tar));

	ctx.call("ucentral", "upload", {file: support_tar, uri: args.uri, uuid: args.serial});
                                              
	result_json({                                             
		"error": 0,                   
		"text": "Success",            
		"resultCode": 0,              
		"resultText": "Uploading file"
	});

%}

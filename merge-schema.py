#!/usr/bin/env python3

import json

merge = {
	"$id": "https://openwrt.org/ucentral.schema.json",
	"$schema": "http://json-schema.org/draft-07/schema#",
	"description": "OpenWrt uCentral schema",
	"type": "object",
	"properties": {
		"uuid": { "type": "integer" }
	}
}

def schema_merge(name, path):
	try:
		with open(path) as infile:
			schema = json.load(infile)
		merge["properties"] = { **merge["properties"], **schema["properties"]}
		print(f"merged {path} as {name}")
	except:
		print(f"failed to merge {path}")

def schema_write():
	try:
		with open(f"ucentral.schema.json", 'w') as outfile:
			json.dump(merge, outfile, indent=True)
	except:
		print("failed to write ucentral.schema.json")

schema_merge("network", "network.schema")
schema_merge("phy", "wifi-phy.schema")
schema_merge("ssid", "wifi-ssid.schema")
schema_merge("system", "system.schema")
schema_merge("log", "log.schema")
schema_merge("ntp", "ntp.schema")
schema_merge("ssh", "ssh.schema")
schema_merge("steer", "steer.schema")
schema_merge("poe", "poe.schema")
schema_merge("lldp", "lldp.schema")
schema_merge("rtty", "rtty.schema")
schema_write()

#!/usr/bin/env python

import json

merge = {
	"$id": "https://openwrt.org/usync.schema.json",
	"$schema": "http://json-schema.org/draft-07/schema#",
	"description": "OpenWrt uSync schema",
	"type": "object",
	"properties": {
		"uuid": { "type": "string" }
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
		with open(f"usync.schema.json", 'w') as outfile:
			json.dump(merge, outfile, indent=True)
	except:
		print("failed to write usync.schema.json")

schema_merge("phy", "wifi-phy.schema")
schema_merge("ssid", "wifi-ssid.schema")
schema_write()

#!/usr/bin/env python

import json

merge = {}

def config_merge(path):
	try:
		with open(path) as infile:
			cfg = json.load(infile)
		for k in cfg:
			merge[k] = cfg[k]
		print(f"merged {path}")
	except:
		print(f"failed to merge {path}")

def config_write():
	try:
		with open(f"usync.cfg", 'w') as outfile:
			json.dump(merge, outfile, indent=True)
	except:
		print("failed to write usync.cfg")

config_merge("wifi-phy.cfg")
config_merge("wifi-ssid.cfg")
config_write()

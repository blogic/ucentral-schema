#!/bin/sh

sed -i "s/\t/        /g" -i schema/*.yml

yaml2json schema/network.yml network.schema
yaml2json schema/system.yml system.schema
yaml2json schema/log.yml log.schema
yaml2json schema/ntp.yml ntp.schema
yaml2json schema/ssh.yml ssh.schema
yaml2json schema/wifi-phy.yml wifi-phy.schema
yaml2json schema/wifi-ssid.yml wifi-ssid.schema
./merge-schema.py
mkdir -p docs
jsonschema2md usync.schema.json docs/usync-schema.md
generate-schema-doc usync.schema.json docs/usync-schema.html

#!/bin/sh

sed -i "s/\t/        /g" -i schema/*.yml

yaml2json schema/network.yml network.schema
yaml2json schema/system.yml system.schema
yaml2json schema/log.yml log.schema
yaml2json schema/ntp.yml ntp.schema
yaml2json schema/ssh.yml ssh.schema
yaml2json schema/wifi-phy.yml wifi-phy.schema
yaml2json schema/wifi-ssid.yml wifi-ssid.schema
yaml2json schema/steer.yml steer.schema
yaml2json schema/poe.yml poe.schema
yaml2json schema/lldp.yml lldp.schema
yaml2json schema/rtty.yml rtty.schema
./merge-schema.py
mkdir -p docs
jsonschema2md ucentral.schema.json docs/ucentral-schema.md
generate-schema-doc ucentral.schema.json docs/ucentral-schema.html

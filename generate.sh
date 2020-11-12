#!/bin/sh

sed -i "s/\t/        /g" -i *.yml

yaml2json network.yml network.schema
yaml2json system.yml system.schema
yaml2json log.yml log.schema
yaml2json ntp.yml ntp.schema
yaml2json ssh.yml ssh.schema
yaml2json wifi-phy.yml wifi-phy.schema
yaml2json wifi-ssid.yml wifi-ssid.schema
./merge-schema.py
jsonschema2md usync.schema.json docs/usync-schema.md
generate-schema-doc usync.schema.json docs/usync-schema.html

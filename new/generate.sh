#!/bin/sh

./merge-schema.py
mkdir -p docs
generate-schema-doc --config expand_buttons=true ucentral.schema.pretty.json docs/ucentral-schema.html

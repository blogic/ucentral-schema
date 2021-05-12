#!/bin/sh

./merge-schema.py schema schema ucentral.yml ucentral.schema.json 1
./merge-schema.py schema schema ucentral.yml ucentral.schema.pretty.json 0
./merge-schema.py state state state.yml ucentral.state.pretty.json 0
mkdir -p docs
generate-schema-doc --config expand_buttons=true ucentral.schema.pretty.json docs/ucentral-schema.html
generate-schema-doc --config expand_buttons=true ucentral.state.pretty.json docs/ucentral-state.html
./generate-reader.uc  > schemareader.uc
./generate-example.uc > input.json

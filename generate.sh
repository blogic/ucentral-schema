#!/bin/sh

set -e
set -x

./merge-schema.py schema schema ucentral.yml ucentral.schema.json 1 1
./merge-schema.py schema schema ucentral.yml ucentral.schema.pretty.json 0 1
./merge-schema.py schema schema ucentral.yml ucentral.schema.full.json 0 0
./merge-schema.py state state state.yml ucentral.state.pretty.json 0 1
./generate-reader.uc  > schemareader.uc
#./generate-example.uc > input.json
mkdir -p docs
which generate-schema-doc > /dev/null
generate-schema-doc --config expand_buttons=true ucentral.schema.pretty.json docs/ucentral-schema.html
generate-schema-doc --config expand_buttons=true ucentral.state.pretty.json docs/ucentral-state.html

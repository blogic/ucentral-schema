#!/usr/bin/env python3

import yaml
import json

def schema_filename(list):
    file = list.split("v1/")
    file.pop(0)
    return file[0].replace("/", ".") + "yml"

def schema_load(filename):
    with open(filename) as stream:
        try:
            schema = yaml.safe_load(stream)
            return schema
        except yaml.YAMLError as exc:
            print(exc)

def schema_compile(input, output, tiny):
    for k in input:
        if tiny and k == "description":
            continue
        if isinstance(input[k], dict):
            if k not in output:
                output[k] = {}
            schema_compile(input[k], output[k], tiny)
        elif k == "$ref" and input[k].startswith("https://"):
            output.update(schema_compile(schema_load(schema_filename(input[k])), {}, tiny))
        elif k == "$ref" and not tiny:
            output["properties"] = {"reference": {"type": "string"}}
        else:
            output[k] = input[k]
    return output

def schema_generate(filename, tiny):
    with open(filename, 'w') as outfile:
        json.dump(schema_compile(schema_load("ucentral.yml"), {}, tiny), outfile, ensure_ascii = tiny and False or True, indent = tiny and 0 or 4)

schema_generate('ucentral.schema.json', 1)
schema_generate('ucentral.schema.pretty.json', 0)

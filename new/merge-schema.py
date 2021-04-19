#!/usr/bin/env python3

import yaml
import json

def schema_filename(list):
    file = list.split("v1/")
    file.pop(0)
    return file[0].replace("/", ".") + "yml"

def entity_name(uri):
    name = uri.replace("https://ucentral.io/schema/v1/", "").rstrip("/")
    return name.replace("/", ".")

def schema_load(filename):
    with open(filename) as stream:
        try:
            schema = yaml.safe_load(stream)
            return schema
        except yaml.YAMLError as exc:
            print(exc)

def schema_compile(input, output, definitions, tiny):
    for k in input:
        if tiny and (k == "description" or k == "uc-example"):
            continue
        if isinstance(input[k], dict):
            if k not in output:
                output[k] = {}
            schema_compile(input[k], output[k], definitions, tiny)
        elif k == "$ref" and input[k].startswith("https://"):
            name = entity_name(input[k])
            definitions[name] = schema_compile(schema_load(schema_filename(input[k])), {}, definitions, tiny)
            output["$ref"] = "#/definitions/{}".format(name)
        elif k == "$ref" and not tiny:
            output["properties"] = {"reference": {"type": "string"}}
        else:
            output[k] = input[k]
    return output

def schema_generate(filename, tiny):
    with open(filename, 'w') as outfile:
        defs = {}
        schema = schema_compile(schema_load("ucentral.yml"), {}, defs, tiny)
        schema["definitions"] = defs
        json.dump(schema, outfile, ensure_ascii = tiny and False or True, indent = tiny and 0 or 4)

schema_generate('ucentral.schema.json', 1)
schema_generate('ucentral.schema.pretty.json', 0)

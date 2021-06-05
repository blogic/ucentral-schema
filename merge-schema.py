#!/usr/bin/env python3

import sys
import yaml
import json

def schema_filename(list):
    file = list.split("v1/")
    file.pop(0)
    return file[0].replace("/", ".") + "yml"

def entity_name(uri):
    name = uri.replace("https://ucentral.io/" + sys.argv[1] + "/v1/", "").rstrip("/")
    return name.replace("/", ".")

def schema_load(filename):
    print(sys.argv[2] + "/" + filename)
    with open(sys.argv[2] + "/" + filename) as stream:
        try:
            schema = yaml.safe_load(stream)
            return schema
        except yaml.YAMLError as exc:
            print(exc)

def schema_compile(input, output, definitions, tiny, refs):
    for k in input:
        if tiny and (k == "description" or k == "uc-example"):
            continue
        if isinstance(input[k], dict):
            if k not in output:
                output[k] = {}
            schema_compile(input[k], output[k], definitions, tiny, refs)
        elif k == "$ref" and input[k].startswith("https://"):
            name = entity_name(input[k])
            compiled = schema_compile(schema_load(schema_filename(input[k])), {}, definitions, tiny, refs)
            if refs:
                definitions[name] = compiled
                output["$ref"] = "#/$defs/{}".format(name)
            else:
                for i in compiled:
                    output[i] = compiled[i]
        elif k == "$ref" and not tiny:
            output["properties"] = {"reference": {"type": "string"}}
        elif k == "anyOf" or k == "oneOf" or k == "allOf":
            r = []
            for v in input[k]:
                o = {}
                schema_compile(v, o, definitions, tiny, refs)
                r.append(o)
            output[k] = r
        else:
            output[k] = input[k]
    return output

def schema_generate():
    with open(sys.argv[4], 'w') as outfile:
        tiny = int(sys.argv[5])
        refs = int(sys.argv[6])
        defs = {}
        schema = schema_compile(schema_load(sys.argv[3]), {}, defs, tiny, refs)
        if refs:
            schema["$defs"] = defs
        json.dump(schema, outfile, ensure_ascii = tiny and False or True, indent = tiny and 0 or 4)

if len(sys.argv) != 7:
    raise Exception("Invalid parameters");

schema_generate()

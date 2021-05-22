#!/usr/bin/env ucode
{%

push(REQUIRE_SEARCH_PATH,
	"/usr/local/lib/ucode/*.so");

let fs = require("fs");
let math = require("math");

function to_property_name(name)
{
	return replace(replace(
		name, //replace(name, /-(.)/g, (_, c) => uc(c)),
		/[^A-Za-z0-9_]+/g,
		'_'
	), /^[0-9]/, '_$&');
}

function to_method_name(verb, name)
{
	return verb + replace(
		replace(name, /(^|-|\.)(.)/g, (_, p, c) => uc(c)),
		/[^A-Za-z0-9_]+/g,
		'_'
	);
}

function to_json_ptr(propertyName)
{
	return replace(propertyName, /[~\/]/g, m => (m == '~' ? '~0' : '~1'));
}


let GeneratorProto = {
	format_validators: {
		"uc-cidr4": {
			desc: 'IPv4 CIDR',
			code: [
				'let m = match(value, /^(auto|[0-9.]+)\\/([0-9]+)$/);',
				'return m ? ((m[1] == "auto" || length(iptoarr(m[1])) == 4) && +m[2] <= 32) : false;'
			]
		},
		"uc-cidr6": {
			desc: 'IPv6 CIDR',
			code: [
				'let m = match(value, /^(auto|[0-9a-fA-F:.]+)\\/([0-9]+)$/);',
				'return m ? ((m[1] == "auto" || length(iptoarr(m[1])) == 16) && +m[2] <= 128) : false;'
			]
		},
		"uc-cidr": {
			desc: 'IPv4 or IPv6 CIDR',
			code: [
				'let m = match(value, /^(auto|[0-9a-fA-F:.]+)\\/([0-9]+)$/);',
				'if (!m) return false;',
				'let l = (m[1] == "auto") ? 16 : length(iptoarr(m[1]));',
				'return (l > 0 && +m[2] <= (l * 8));'
			]
		},
		"uc-mac": {
			desc: 'MAC address',
			code: [
				'return match(value, /^[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]$/i);'
			]
		},
		"uc-host": {
			desc: 'hostname or IP address',
			code: [
				'if (length(iptoarr(value)) != 0) return true;',
				'if (length(value) > 255) return false;',
				'let labels = split(value, ".");',
				'return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);'
			]
		},
		"uc-timeout": {
			desc: 'timeout value',
			code: [
				'return match(value, /^[0-9]+[smhdw]$/);'
			]
		},
		"hostname": {
			desc: 'hostname',
			code: [
				'if (length(value) > 255) return false;',
				'let labels = split(value, ".");',
				'return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);'
			]
		},
		"fqdn": {
			desc: 'fully qualified domain name',
			code: [
				'if (length(value) > 255) return false;',
				'let labels = split(value, ".");',
				'return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 1);'
			]
		},
		"ipv4": {
			desc: 'IPv4 address',
			code: [
				'return (length(iptoarr(value)) == 4);'
			]
		},
		"ipv6": {
			desc: 'IPv6 address',
			code: [
				'return (length(iptoarr(value)) == 16);'
			]
		},
		"uri": {
			desc: 'URI',
			code: [
				'if (index(value, "data:") == 0) return true;',
				'let m = match(value, /^[a-z+-]+:\\/\\/([^\\/]+).*$/);',
				'if (!m) return false;',
				'if (length(iptoarr(m[1])) != 0) return true;',
				'if (length(m[1]) > 255) return false;',
				'let labels = split(m[1], ".");',
				'return (length(filter(labels, label => !match(label, /^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])$/))) == 0 && length(labels) > 0);'
			]
		}
	},

	is_ref: function(value)
	{
		return (
			type(value) == "object" &&
			exists(value, "$ref") &&
			//length(value) == 1 &&
			type(value["$ref"]) == "string"
		) ? value["$ref"] : null;
	},

	emit_test_expression: function(path, condExpr, errorMsg, isTerminal)
	{
		this.print(path, 'if (%s)%s', condExpr, isTerminal ? ' {' : '');
		this.print(path, '	push(errors, [ location, %J ]);', errorMsg);

		if (isTerminal) {
			this.print(path, '	return null;');
			this.print(path, '}');
		}

		this.print(path, '');
	},

	emit_format_asserts: function(path, valueExpr, valueSpec)
	{
		if (!valueSpec.format)
			return;

		if (!exists(this.format_validators, valueSpec.format)) {
			warn("Unrecognized string format '" + valueSpec.format + '".\n');
			return;
		}

		this.emit_test_expression(path,
			sprintf('!%s(%s)', to_method_name('match', valueSpec.format), valueExpr),
			sprintf('must be a valid %s', this.format_validators[valueSpec.format].desc),
			false);
	},

	emit_generic_asserts: function(path, valueExpr, valueSpec)
	{
		if (type(valueSpec.enum) == 'array' && length(valueSpec.enum) > 0)
			this.emit_test_expression(path,
				sprintf('!(%s in %J)', valueExpr, valueSpec.enum),
				sprintf('must be one of %J', valueSpec.enum),
				false);

		if (exists(valueSpec, 'const'))
			this.emit_test_expression(path,
				sprintf('%s != %J', valueExpr, valueSpec.const),
				sprintf('must have value %J', valueSpec.const),
				false);
	},

	emit_number_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'multipleOf')) {
			this.emit_test_expression(path,
				sprintf('%s / %J != int(%s / %J)', valueExpr, valueSpec.multipleOf, valueExpr, valueSpec.multipleOf),
				sprintf('must be divisible by %J', valueSpec.multipleOf),
				false);
		}

		let constraints = {
			'maximum': [ '>', 'lower than or equal to' ],
			'minimum': [ '<', 'bigger than or equal to' ],
			'exclusiveMaximum': [ '>=', 'lower than' ],
			'exclusiveMinimum': [ '<=', 'bigger than' ]
		};

		for (let keyword, op_desc in constraints) {
			if (exists(valueSpec, keyword))
				this.emit_test_expression(path,
					sprintf('%s %s %J', valueExpr, op_desc[0], valueSpec[keyword]),
					sprintf('must be %s %J', op_desc[1], valueSpec[keyword]),
					false);
		}
	},

	emit_string_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'pattern')) {
			try {
				regexp(valueSpec.pattern);

				this.emit_test_expression(path,
					sprintf('!match(%s, regexp(%J))', valueExpr, valueSpec.pattern),
					sprintf('must match regular expression /%s/', valueSpec.pattern),
					false);
			}
			catch (e) {
				warn("Uncompilable regular expression '" + valueSpec.pattern + "': " + e + '.\n');
			}
		}

		if (exists(valueSpec, 'maxLength')) {
			this.emit_test_expression(path,
				sprintf('length(%s) > %J', valueExpr, valueSpec.maxLength),
				sprintf('must be at most %J characters long', valueSpec.maxLength),
				false);
		}

		if (exists(valueSpec, 'minLength')) {
			this.emit_test_expression(path,
				sprintf('length(%s) < %J', valueExpr, valueSpec.minLength),
				sprintf('must be at least %J characters long', valueSpec.maxLength),
				false);
		}
	},

	emit_array_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'maxItems')) {
			this.emit_test_expression(path,
				sprintf('length(%s) > %J', valueExpr, valueSpec.maxItems),
				sprintf('must not have more than %J items', valueSpec.maxItems),
				false);
		}

		if (exists(valueSpec, 'minItems')) {
			this.emit_test_expression(path,
				sprintf('length(%s) < %J', valueExpr, valueSpec.minItems),
				sprintf('must have at least %J items', valueSpec.minItems),
				false);
		}

		/* XXX: uniqueItems, maxContains, minContains */
	},

	emit_object_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'maxProperties')) {
			this.emit_test_expression(path,
				sprintf('length(%s) > %J', valueExpr, valueSpec.maxProperties),
				sprintf('must have at most %J properties', valueSpec.maxProperties),
				false);
		}

		if (exists(valueSpec, 'minProperties')) {
			this.emit_test_expression(path,
				sprintf('length(%s) < %J', valueExpr, valueSpec.minProperties),
				sprintf('must have at least %J properties', valueSpec.minProperties),
				false);
		}
	},

	read_schema: function(path)
	{
		let fd = fs.open(path, "r");

		if (!fd)
			return {};

		let schema = json(fd.read("all"));

		fd.close();

		return schema;
	},

	print: function(path, fmt, ...args)
	{
		if (length(fmt)) {
			for (let _ in path)
				print("\t");

			printf(fmt, ...args);
		}

		print("\n");
	},

	emit_spec_validation_asserts: function(path, valueExpr, valueSpec)
	{
		let typeMap = {
			string: 'type(%s) != "string"',
			number: '!(type(%s) in [ "int", "double" ])',
			integer: 'type(%s) != "int"',
			boolean: 'type(%s) != "bool"',
			array: 'type(%s) != "array"',
			object: 'type(%s) != "object"'
		};

		if (exists(typeMap, valueSpec.type)) {
			this.emit_test_expression(path,
				sprintf(typeMap[valueSpec.type], valueExpr),
				sprintf('must be of type %s', valueSpec.type),
				true);
		}

		this.emit_generic_asserts(path, valueExpr, valueSpec);
		this.emit_format_asserts(path, valueExpr, valueSpec);

		let variantSpecs, variantErrorCond, variantErrorMsg;

		if (type(valueSpec.anyOf) == "array" && length(valueSpec.anyOf) > 0) {
			variantSpecs = valueSpec.anyOf;
			variantErrorCond = '== 0';
			variantErrorMsg = 'at least one';
		}
		else if (type(valueSpec.oneOf) == "array" && length(valueSpec.oneOf) > 0) {
			variantSpecs = valueSpec.oneOf;
			variantErrorCond = '!= 1';
			variantErrorMsg = 'exactly one';
		}
		else if (type(valueSpec.allOf) == "array" && length(valueSpec.allOf) > 0) {
			variantSpecs = valueSpec.allOf;
			variantErrorCond = sprintf('!= %d', length(variantSpecs));
			variantErrorMsg = 'all';
		}

		if (variantSpecs) {
			let functionNames = [];

			for (let i, subSpec in variantSpecs)
				push(functionNames, this.emit_spec_validation_function(path, 'parseVariant', i, subSpec));

			this.print(path, 'let success = 0, tryval, tryerr, verrors = [];\n');

			for (let functionName in functionNames) {
				this.print(path, 'tryerr = [];');
				this.print(path, 'tryval = %s(location, value, tryerr);', functionName);
				this.print(path, 'if (!length(tryerr)) {');
				this.print(path, '	value = tryval;');
				this.print(path, '	success++;');
				this.print(path, '}');
				this.print(path, 'else {');
				this.print(path, '	push(verrors, join(" and\\n", map(tryerr, err => "\\t - " + err[1])));');
				this.print(path, '}\n');
			}

			this.print(path, 'if (success %s) {', variantErrorCond);
			this.print(path, '	push(errors, [ location, "must match %s of the following constraints:\\n" + join("\\n- or -\\n", verrors) ]);', variantErrorMsg);
			this.print(path, '	return null;');
			this.print(path, '}\n');
		}

		switch (valueSpec.type) {
		case 'number':
		case 'integer':
			this.emit_number_asserts(path, valueExpr, valueSpec);
			break;

		case 'string':
			this.emit_string_asserts(path, valueExpr, valueSpec);
			break;

		case 'array':
			this.emit_array_asserts(path, valueExpr, valueSpec);
			break;

		case 'object':
			this.emit_object_asserts(path, valueExpr, valueSpec);
			break;
		}
	},

	emit_format_validation_function: function(path, verb, formatName, formatCode)
	{
		let functionName = to_method_name(verb, formatName);

		this.print(path, 'function %s(value) {', functionName);

		for (let line in formatCode)
			this.print(path, '	' + line);

		this.print(path, '}\n');
	},

	emit_spec_validation_function: function(path, verb, propertyName, valueSpec)
	{
		let functionName = to_method_name(verb, propertyName),
		    isRef = this.is_ref(valueSpec);

		this.print(path, 'function %s(location, value, errors) {', functionName);

		this.emit_spec_validation_asserts([...path, propertyName], 'value', valueSpec);

		/* Derive type from referenced subschema if possible */
		if (!exists(valueSpec, 'type') && isRef) {
			let def = this.schema['$defs'][replace(isRef, '#/$defs/', '')];
			valueSpec.type = def ? def.type : null;
		}

		switch (valueSpec.type) {
		case 'array':
			let itemSpec = valueSpec.items,
			    isRef = this.is_ref(itemSpec);

			if (type(itemSpec) == "object") {
				if (isRef) {
					this.print(path, '	return map(value, (item, i) => %s(location + "/" + i, item, errors));',
						to_method_name('instantiate', replace(isRef, '#/$defs/', '')));
				}
				else {
					this.emit_spec_validation_function([...path, propertyName], 'parse', 'item', itemSpec);
					this.print(path, '	return map(value, (item, i) => parseItem(location + "/" + i, item, errors));');
				}
			}
			else {
				this.print(path, '	return value;');
			}

			break;

		case 'object':
			if (type(valueSpec.propertyNames) == "object") {
				let keySpec = { type: 'string', ...(valueSpec.propertyNames) };

				this.print(path, '	for (let propertyName in value) {');
				this.emit_spec_validation_asserts([...path, propertyName, '$'], 'propertyName', keySpec);
				this.print(path, '	}');
				this.print(path, '');
			}

			if (exists(valueSpec, "$ref")) {
				let fn = to_method_name('instantiate', replace(valueSpec['$ref'], '#/$defs/', ''));

				if (valueSpec.additionalProperties === true)
					this.print(path, '	let obj = { ...value, ...(%s(location, value, errors)) };\n', fn);
				else
					this.print(path, '	let obj = %s(location, value, errors);\n', fn);
			}
			else {
				if (valueSpec.additionalProperties === true)
					this.print(path, '	let obj = { ...value };\n');
				else
					this.print(path, '	let obj = {};\n');
			}

			if (type(valueSpec.properties) == "object") {
				for (let objectPropertyName, propertySpec in valueSpec.properties) {
					let valueExpr = sprintf('value[%J]', objectPropertyName),
					    isRef = this.is_ref(propertySpec);

					if (!isRef) {
						this.emit_spec_validation_function(
							[...path, propertyName],
							'parse',
							objectPropertyName,
							propertySpec);
					}

					this.print(path, '	if (exists(value, %J)) {',
						objectPropertyName);

					if (isRef) {
						this.print(path, '		obj.%s = %s(location + "/%s", %s, errors);',
							to_property_name(objectPropertyName),
							to_method_name('instantiate', replace(isRef, '#/$defs/', '')),
							to_json_ptr(objectPropertyName),
							valueExpr);
					}
					else {
						this.print(path, '		obj.%s = %s(location + "/%s", %s, errors);',
							to_property_name(objectPropertyName),
							to_method_name('parse', objectPropertyName),
							to_json_ptr(objectPropertyName),
							valueExpr);
					}

					this.print(path, '	}');

					if (exists(propertySpec, 'default')) {
						this.print(path, '	else {');

						this.print(path, '		obj.%s = %J;',
							to_property_name(objectPropertyName),
							propertySpec.default);

						this.print(path, '	}');
					}
					else if (objectPropertyName in valueSpec.required) {
						this.print(path, '	else {');
						this.print(path, '		push(errors, [ location, "is required" ]);');
						this.print(path, '	}');
					}

					this.print(path, '');
				}
			}

			this.print(path, '	return obj;');
			break;

		default:
			this.print(path, '	return value;');
			break;
		}

		this.print(path, '}\n');

		return functionName;
	},

	generate: function()
	{
		let path = [];

		this.schema = this.read_schema(this.path);

		this.print(path, '{%');
		this.print(path, '// Automatically generated from %s - do not edit!', this.path);
		this.print(path, '"use strict";\n');

		for (let formatName, formatCode in this.format_validators)
			this.emit_format_validation_function(path, 'match', formatName, formatCode.code);

		for (let definitionId, definitionSpec in this.schema['$defs'])
			this.emit_spec_validation_function(path, 'instantiate', definitionId, definitionSpec);

		this.emit_spec_validation_function(path, 'new', "UCentralState", this.schema);

		this.print(path, 'return {');
		this.print(path, '	validate: (value, errors) => {');
		this.print(path, '		let err = [];');
		this.print(path, '		let res = newUCentralState("", value, err);');
		this.print(path, '		if (errors) push(errors, ...map(err, e => "[E] (In " + e[0] + ") Value " + e[1]));');
		this.print(path, '		return length(errors) ? null : res;');
		this.print(path, '	}');
		this.print(path, '};');
	}
};

function instantiateGenerator(path) {
	return proto({ path }, GeneratorProto);
}

let generator = instantiateGenerator("./ucentral.schema.pretty.json");

generator.generate();

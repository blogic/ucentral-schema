#!/usr/bin/env ucode
{%

push(REQUIRE_SEARCH_PATH,
	"/usr/local/lib/ucode/*.so");

let fs = require("fs");
let math = require("math");

function assert(condition, message)
{
	if (!condition)
		die(message);
}

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

function to_value_descr(path)
{
	if (path[length(path) - 1] == '#') {
		let p = [...path]; pop(p);
		return sprintf('Items of %s', join('.', p));
	}
	else {
		return sprintf('Property %s', join('.', path));
	}
}


let GeneratorProto = {
	is_ref: function(value)
	{
		return (
			type(value) == "object" &&
			exists(value, "$ref") &&
			//length(value) == 1 &&
			type(value["$ref"]) == "string"
		) ? value["$ref"] : null;
	},

	is_number: function(value)
	{
		if (type(value) == "int" || type(value) == "double")
			return value;

		return NaN;
	},

	lookup_ptr: function(ptr)
	{
		let m = match(ptr, /^([^#]*)#(\/.*)$/);

		if (!m)
			return null;

		// Can't resolve cross-document references yet
		if (m[1] != "")
			return null;

		let ref = null;

		for (let idx, part in split(m[2], "/")) {
			part = replace(part, /~[01]/g, (m) => (m == "~0" ? "~" : "/" ));

			if (idx == 0)
				ref = this.schema;
			else if (type(ref) == "object" || type(ref) == "array")
				ref = ref[part];
			else
				return null;
		}

		return ref;
	},

	emit_generic_asserts: function(path, valueExpr, valueSpec)
	{
		if (type(valueSpec.enum) == 'array' && length(valueSpec.enum) > 0)
			this.print(path, 'assert(%s in %J, %J);',
				valueExpr, valueSpec.enum,
				sprintf('%s must be one of %J', to_value_descr(path), valueSpec.enum));

		if (exists(valueSpec, 'const'))
			this.print(path, 'assert(%s == %J, %J);',
				valueExpr, valueSpec.const,
				sprintf('%s must be %J', to_value_descr(path), valueSpec.const));
	},

	emit_number_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'multipleOf')) {
			this.print(path, 'assert(%s / %J == int(%s / %J), %J);',
				valueExpr, valueSpec.multipleOf,
				valueExpr, valueSpec.multipleOf,
				sprintf('%s must be divisible by %J',
					to_value_descr(path), valueSpec.multipleOf));
		}

		let constraints = {
			'maximum': '<=',
			'minimum': '=>',
			'exclusiveMaximum': '<',
			'exclusiveMinimum': '>'
		};

		for (let keyword, op in constraints) {
			if (exists(valueSpec, keyword))
				this.print(path, 'assert(%s %s %J, %J);',
					valueExpr, op, valueSpec[keyword],
					sprintf('%s must be %s %J', to_value_descr(path), op, valueSpec[keyword]));
		}
	},

	emit_string_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'pattern')) {
			/* XXX: validate regexp */
			this.print(path, 'assert(match(%s, /%s/), %J);\n',
				valueExpr, valueSpec.pattern,
				sprintf('%s must match regular expression /%s/', to_value_descr(path), valueSpec.pattern));
		}

		if (exists(valueSpec, 'maxLength')) {
			this.print(path, 'assert(length(%s) <= %J, %J);\n',
				value_expr, valueSpec.maxLength,
				sprintf('%s must be <= %J characters long', to_value_descr(path), valueSpec.maxLength));
		}

		if (exists(valueSpec, 'minLength')) {
			this.print(path, 'assert(length(%s) >= %J, %J);\n',
				value_expr, valueSpec.minLength,
				sprintf('%s must be >= %J characters long', to_value_descr(path), valueSpec.minLength));
		}
	},

	emit_array_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'maxItems')) {
			this.print(path, 'assert(length(%s) <= %J, %J);\n',
				value_expr, valueSpec.maxItems,
				sprintf('%s array length must be <= %J items', to_value_descr(path), valueSpec.maxItems));
		}

		if (exists(valueSpec, 'minItems')) {
			this.print(path, 'assert(length(%s) >= %J, %J);\n',
				value_expr, valueSpec.minItems,
				sprintf('%s array length must be >= %J items', to_value_descr(path), valueSpec.minItems));
		}

		/* XXX: uniqueItems, maxContains, minContains */
	},

	emit_object_asserts: function(path, valueExpr, valueSpec)
	{
		if (exists(valueSpec, 'maxProperties')) {
			this.print(path, 'assert(length(%s) <= %J, %J);\n',
				value_expr, valueSpec.maxProperties,
				sprintf('%s object must have <= %J properties', to_value_descr(path), valueSpec.maxProperties));
		}

		if (exists(valueSpec, 'minProperties')) {
			this.print(path, 'assert(length(%s) >= %J, %J);\n',
				value_expr, valueSpec.minProperties,
				sprintf('%s object must have >= %J properties', to_value_descr(path), valueSpec.minProperties));
		}
	},

	emit_constraints: function(propertyName, valueSpec)
	{
		this.emit_generic_asserts(propertyName, valueSpec);

		switch (valueSpec.type) {
		case 'integer':
			this.emit_number_asserts(propertyName, valueSpec, true);
			break;

		case 'number':
			this.emit_number_asserts(propertyName, valueSpec, false);
			break;

		case 'string':
			this.emit_string_asserts(propertyName, valueSpec);
			break;

		case 'array':
			this.emit_array_asserts(propertyName, valueSpec);
			break;

		case 'object':
			this.emit_object_asserts(propertyName, valueSpec);
			break;
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
		for (let _ in path)
			print("\t");

		printf(fmt, ...args);
		print("\n");
	},

	is_simple_spec: function(valueSpec)
	{
		switch (valueSpec.type) {
		case 'string':
		case 'number':
		case 'integer':
		case 'boolean':
			return true;

		default:
			return false;
		}
	},

	emit_spec_validation_asserts: function(path, valueExpr, propertyName, valueSpec)
	{
		//this.print(path, '// Asserts for %s / %J / %J',
		//	valueExpr, propertyName, valueSpec);

		let typeMap = {
			string: '== "string"',
			number: 'in [ "int", "double" ]',
			integer: '== "int"',
			boolean: '== "bool"',
			array: '== "array"',
			object: '== "object"'
		};

		this.print(path, 'assert(type(%s) %s, %J);',
			valueExpr, typeMap[valueSpec.type],
			sprintf('%s must be of type %s',
				to_value_descr(path), valueSpec.type));

		this.emit_generic_asserts(path, valueExpr, valueSpec);

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

	emit_spec_validation_function: function(path, verb, propertyName, valueSpec)
	{
		this.print(path, 'function %s(value) {', to_method_name(verb, propertyName));

		this.emit_spec_validation_asserts([...path, propertyName], 'value', propertyName, valueSpec);

		this.print(path, '');

		switch (valueSpec.type) {
		case 'string':
		case 'number':
		case 'integer':
		case 'boolean':
			this.print(path, '	return value;');
			break;

		case 'array':
			let itemSpec = valueSpec.items,
			    isSimple = this.is_simple_spec(itemSpec),
			    isRef = this.is_ref(itemSpec);

			if (type(itemSpec) == "object") {
				if (isRef) {
					this.print(path, '	return map(value, %s);',
						to_method_name('instantiate', replace(isRef, '#/$defs/', '')));
				}
				else if (isSimple) {
					this.print(path, '	return map(value, (item) => {');
					//this.print(path, '		// Array %J item asserts...\n', propertyName);
					this.emit_spec_validation_asserts([...path, propertyName, '#'], 'item', propertyName, valueSpec);
					this.print(path, '		return item;');
					this.print(path, '	});');
				}
				else {
					this.emit_spec_validation_function([...path, propertyName], 'parse', 'item', valueSpec.items);
					this.print(path, '	return map(value, parseItem);');
				}
			}
			else {
				this.print(path, '	return value;');
			}

			break;

		case 'object':
			/* XXX: not yet */
			if (exists(valueSpec, "$ref"))
				return;

			this.print(path,	'	let obj = {};\n');

			if (type(valueSpec.properties) == "object") {
				for (let objectPropertyName, propertySpec in valueSpec.properties) {
					let valueExpr = sprintf('value[%J]', objectPropertyName),
					    isSimple = this.is_simple_spec(propertySpec),
					    isRef = this.is_ref(propertySpec);

					if (!isSimple && !isRef) {
						this.emit_spec_validation_function(
							[...path, propertyName],
							'parse',
							objectPropertyName,
							propertySpec);
					}

					this.print(path, '	if (exists(value, %J)) {',
						objectPropertyName);

					if (isRef) {
						this.print(path, '		obj.%s = %s(%s);',
							to_property_name(objectPropertyName),
							to_method_name('instantiate', replace(isRef, '#/$defs/', '')),
							valueExpr);
					}
					else if (isSimple) {
						this.emit_spec_validation_asserts(
							[...path, propertyName, objectPropertyName],
							valueExpr,
							objectPropertyName,
							propertySpec);

						this.print(path, '		obj.%s = %s;',
							to_property_name(objectPropertyName),
							valueExpr);
					}
					else {
						this.print(path, '		obj.%s = %s(%s);',
							to_property_name(objectPropertyName),
							to_method_name('parse', objectPropertyName),
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

						this.print(path, '		assert(false, %J);',
							sprintf('Property %J is required', objectPropertyName));

						this.print(path, '	}');
					}

					this.print(path, '');
				}
			}

			this.print(path, '	return obj;');
		}

		this.print(path, '}\n');
	},

	generate: function()
	{
		let path = [];

		this.schema = this.read_schema(this.path);

		for (let definitionId, definitionSpec in this.schema['$defs'])
			this.emit_spec_validation_function(path, 'instantiate', definitionId, definitionSpec);

		this.emit_spec_validation_function(path, 'new', "UCentralState", this.schema);
	}
};

function instantiateGenerator(path) {
	return proto({ path }, GeneratorProto);
}

let generator = instantiateGenerator("./ucentral.schema.pretty.json");
let document = generator.generate();

//print(document, "\n");

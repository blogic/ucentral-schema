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

function random_string(len)
{
	let chars = [];

	for (let i = 0; i < len; i++) {
		let b = math.rand() % 52;
		push(chars, (b > 26 ? 65 : 97) + (b % 26));
	}

	return chr(...chars);
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

	emit_generic: function(objectSpec)
	{
		if (type(objectSpec.enum) == "array" && length(objectSpec.enum) > 0)
			return objectSpec.enum[math.rand() % length(objectSpec.enum)];

		if (exists(objectSpec, "const"))
			return objectSpec.const;

		return NaN;
	},

	emit_object: function(objectSpec)
	{
		let object = {};

		assert(objectSpec.type == "object", "Expecting object type");

		if (type(objectSpec.properties) == "object") {
			for (let propertyName, propertySpec in objectSpec.properties) {
				let value = this.emit_spec(propertySpec);

				object[propertyName] = value;
			}
		}

		return object;
	},

	emit_array: function(arraySpec)
	{
		let array = [];

		assert(arraySpec.type == "array", "Expecting array type");

		if (type(arraySpec.items) == "object") {
			let len = 3;

			if (type(arraySpec.minItems) == "int" && arraySpec.minItems > len)
				len = arraySpec.minItems;

			for (let i = 0; i < len; i++)
				push(array, this.emit_spec(arraySpec.items));
		}

		return array;
	},

	emit_string: function(stringSpec)
	{
		assert(stringSpec.type == "string", "Expecting string type");

		let rv = this.emit_generic(stringSpec);

		if (rv == rv)
			return rv;

		if (exists(stringSpec, "uc-example"))
			return stringSpec["uc-example"];
		else if (exists(stringSpec, "default"))
			return stringSpec["default"];

		let len = 10;

		if (type(stringSpec.minLength) == "int" && stringSpec.minLength > len)
			len = stringSpec.minLength;

		if (type(stringSpec.maxLength) == "int" && stringSpec.maxLength < len)
			len = stringSpec.maxLength;

		return random_string(len);
	},

	emit_number: function(numberSpec)
	{
		assert(numberSpec.type == "number", "Expecting number type");

		let rv = this.emit_generic(numberSpec);

		if (rv == rv)
			return rv;

		let multiplicator = 1;

		if (type(numberSpec["default"]) == "double" || type(numberSpec["uc-example"]) == "double")
			multiplicator = 0.1;

		if (this.is_number(numberSpec.multipleOf) > 0)
			multiplicator = numberSpec.multipleOf;

		let min = this.is_number(numberSpec.minimum);
		let max = this.is_number(numberSpec.maximum);
		let exMin = this.is_number(numberSpec.exclusiveMinimum);
		let exMax = this.is_number(numberSpec.exclusiveMaximum);

		while (true) {
			let n = multiplicator * math.rand();

			if (max == max)
				n = n % max;
			else if (exMax == exMax)
				n = n % exMax;

			if (min == min && n < min)
				continue;

			if (exMin == exMin && n <= min)
				continue;

			return n;
		}
	},

	emit_boolean: function(boolSpec)
	{
		assert(boolSpec.type == "boolean", "Expecting boolean type");

		let rv = this.emit_generic(boolSpec);

		if (rv == rv)
			return rv;

		if (exists(boolSpec, "uc-example"))
			return (boolSpec["uc-example"] == true);
		else if (exists(boolSpec, "default"))
			return (boolSpec["default"] == true);

		return false;
	},

	emit_spec: function(valueSpec)
	{
		let ref = this.is_ref(valueSpec);

		if (ref) {
			let refValueSpec = this.lookup_ptr(ref);

			assert(type(refValueSpec) == "object",
				"$ref value '"  + ref + "' points to non-object value");

			valueSpec = { ...refValueSpec, ...valueSpec };
		}

		switch (valueSpec.type) {
		case "object":
			return this.emit_object(valueSpec);

		case "array":
			return this.emit_array(valueSpec);

		case "string":
			return this.emit_string(valueSpec);

		case "number":
			return this.emit_number(valueSpec);

		case "boolean":
			return this.emit_boolean(valueSpec);

		default:
			warn("Unknown type " + valueSpec.type + " (" + valueSpec + ")\n");
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

	generate: function()
	{
		this.schema = this.read_schema(this.path);

		return this.emit_spec(this.schema);
	}
};

function createGenerator(path) {
	return proto({ path }, GeneratorProto);
}

let generator = createGenerator("./ucentral.schema.pretty.json");
let document = generator.generate();

print(document, "\n");

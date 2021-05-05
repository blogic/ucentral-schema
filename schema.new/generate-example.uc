#!/usr/bin/env ucode
{%

push(REQUIRE_SEARCH_PATH,
	"/usr/local/lib/ucode/*.so");

let fs = require("fs");
let math = require("math");

// words sourced from https://github.com/imsky/wordlists/
let verbs = [
	'access', 'address', 'bookmark', 'browse', 'build', 'chat', 'click', 'close', 'code', 'compile', 'connect',
	'debug', 'deploy', 'develop', 'download', 'downsize', 'drag', 'evangelize', 'execute', 'flub', 'generate',
	'insource', 'install', 'link', 'load', 'log', 'make', 'marinate', 'message', 'noodle', 'onboard', 'open',
	'paper', 'patch', 'ping', 'populate', 'post', 'productize', 'receive', 'release', 'resonate', 'run', 'scroll',
	'search', 'send', 'share', 'step', 'sunset', 'surface', 'task', 'transition', 'triangulate', 'type', 'unpack',
	'upload', 'vector', 'view', 'visit'
];

let nouns = [
	'admin', 'agreeance', 'alignment', 'application', 'architecture', 'argument', 'availability', 'backburner',
	'bandwidth', 'baseline', 'benefit', 'block', 'boondoggle', 'brass', 'buy-in', 'capital', 'chain', 'channel',
	'code', 'comment', 'community', 'content', 'convergence', 'coopetition', 'cowboy', 'creative', 'data', 'deck',
	'deliverable', 'delta', 'dialogue', 'disconnect', 'dog', 'empowerment', 'experience', 'expertise', 'float',
	'flunky', 'function', 'functionality', 'gatekeeper', 'gofer', 'goldbricker', 'hardball', 'idea', 'ideation',
	'imperative', 'improvement', 'infomediary', 'information', 'infrastructure', 'initiative', 'innovation',
	'integer', 'interface', 'issue', 'item', 'keyword', 'kicker', 'kudos', 'language', 'leadership', 'learning',
	'line', 'linkage', 'literal', 'market', 'material', 'method', 'methodology', 'metrics', 'mindshare', 'model',
	'name', 'network', 'niche', 'number', 'object', 'opportunity', 'ownership', 'paradigm', 'parameter',
	'partnership', 'pivot', 'platform', 'portal', 'potentiality', 'practice', 'procedure', 'process', 'product',
	'pushback', 'relationship', 'report', 'resource', 'result', 'runway', 'scenario', 'schema', 'scope', 'scrub',
	'service', 'shrink', 'sidebar', 'silo', 'skill', 'skillset', 'snippet', 'solution', 'source', 'space',
	'strategy', 'string', 'synergy', 'syntax', 'system', 'talent', 'technology', 'type', 'upside', 'value',
	'vector', 'verbiage', 'vision'
];

let adjectives = [
	'absolute', 'achromatic', 'acoustic', 'adiabatic', 'alternating', 'atomic', 'binding', 'brownian', 'buoyant',
	'central', 'chief', 'chromatic', 'closed', 'coherent', 'corporate', 'critical', 'customer', 'dense', 'direct',
	'direct', 'district', 'dynamic', 'electric', 'electrical', 'endothermic', 'exothermic', 'forward', 'free',
	'fundamental', 'future', 'global', 'gravitational', 'human', 'internal', 'internal', 'international',
	'isobaric', 'isochoric', 'isothermal', 'kinetic', 'latent', 'lead', 'legacy', 'magnetic',  'mechanical',
	'national', 'natural', 'nuclear', 'open', 'optical', 'potential', 'primary', 'principal', 'progressive',
	'quantum', 'radiant', 'radioactive', 'rectilinear', 'regional', 'relative', 'resolving', 'resonnt',
	'resultant', 'rigid', 'senior', 'volumetric'
];

function is_array(val)
{
	return (type(val) == "array" && length(val) > 0);
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

function random_item(array)
{
	if (type(array) != "array")
		return null;

	return array[math.rand() % length(array)];
}

function random_phrase(min, max) {
	let str, len;

	while (true) {
		let verb = random_item(verbs),
		    adjective, noun;

		while (true) {
			adjective = random_item(adjectives);

			if (adjective != verb)
				break;
		}

		while (true) {
			noun = random_item(nouns);

			if (noun != verb && noun != adjective)
				break;
		}

		str = verb + '-' + adjective + '-' + noun;
		len = length(str);

		if (len >= min && len <= max)
			break;
	}

	return str;
}

function random_ip4addr() {
	return sprintf(random_item([
		'10.%d.%d.%d',
		'172.16.%d.%d',
		'172.17.%d.%d',
		'172.18.%d.%d',
		'172.19.%d.%d',
		'172.20.%d.%d',
		'172.21.%d.%d',
		'172.22.%d.%d',
		'172.23.%d.%d',
		'172.24.%d.%d',
		'172.25.%d.%d',
		'172.26.%d.%d',
		'172.27.%d.%d',
		'172.28.%d.%d',
		'172.29.%d.%d',
		'172.30.%d.%d',
		'172.31.%d.%d',
		'192.168.%d.%d'
	]), math.rand() % 256, math.rand() % 256, math.rand() % 256);
}

function random_ip6addr() {
	return sprintf('2001:db8:%x:%x:%x:%x:%x:%x',
		math.rand() % 0x10000, math.rand() % 0x10000, math.rand() % 0x10000,
		math.rand() % 0x10000, math.rand() % 0x10000, math.rand() % 0x10000);
}

function random_hostname() {
	return random_phrase(0, Infinity) + '.example.org';
}

function random_email() {
	return random_phrase(0, Infinity) + '@example.org';
}

function random_uri() {
	return 'https://example.org/' + random_phrase(0, Infinity);
}

function random_value(kind, minLength, maxLength) {
	switch (kind) {
	case 'ipv4':
		return random_ip4addr();

	case 'ipv6':
		return random_ip6addr();

	case 'email':
	case 'idn-email':
		return random_email();

	case 'hostname':
	case 'idn-hostname':
		return random_hostname();

	case 'uri':
	case 'uri-reference':
	case 'iri':
	case 'iri-reference':
		return random_uri();

	case 'uc-ip':
		switch (math.rand() % 2) {
		case 0: return random_ip4addr();
		case 1: return random_ip6addr();
		}

		break;

	case 'uc-host':
		switch (math.rand() % 3) {
		case 0: return random_hostname();
		case 1: return random_ip4addr();
		case 2: return random_ip6addr();
		}

		break;

	case 'uc-mac':
		return sprintf('02:%02x:%02x:%02x:%02x:%02x',
			math.rand() % 256, math.rand() % 256,
			math.rand() % 256, math.rand() % 256,
			math.rand() % 256);

	case 'uc-cidr4':
		return sprintf('%s/%d',
			random_ip4addr(), math.rand() % 33);

	case 'uc-cidr6':
		return sprintf('%s/%d',
			random_ip6addr(), math.rand() % 129);

	case 'uc-cidr':
		switch (math.rand() % 2) {
		case 0: return sprintf('%s/%d', random_ip4addr(), math.rand() % 33);
		case 1: return sprintf('%s/%d', random_ip6addr(), math.rand() % 129);
		}

		break;

	default:
		if (minLength <= 15 && maxLength >= 20)
			return random_phrase(minLength, maxLength);
		else
			return random_string(minLength + (math.rand() % ((maxLength - minLength) + 1)));
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

	emit_generic: function(objectSpec)
	{
		if (is_array(objectSpec.enum))
			return random_item(objectSpec.enum);

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

			if (is_array(arraySpec.items.enum) && length(arraySpec.items.enum) < len)
				len = length(arraySpec.items.enum);

			let examples = [ ...(is_array(arraySpec.items.examples) ? arraySpec.items.examples : []) ];

			for (let i = 0; i < len; i++) {
				while (true) {
					let item;

					if (length(examples)) {
						item = random_item(examples);
						examples = filter(examples, (i) => i != item);
					}
					else {
						item = this.emit_spec(arraySpec.items, true);
					}

					if (arraySpec.items.type != "string" || index(array, item) == -1) {
						push(array, item);
						break;
					}
				}
			}
		}

		return array;
	},

	emit_string: function(stringSpec, noExample)
	{
		assert(stringSpec.type == "string", "Expecting string type");

		let rv = this.emit_generic(stringSpec);

		if (rv == rv)
			return rv;

		if (!noExample && is_array(stringSpec.examples))
			return random_item(stringSpec.examples);
		else if (exists(stringSpec, "default"))
			return stringSpec.default;

		let minLength = 0;
		let maxLength = 256;

		if (type(stringSpec.minLength) == "int")
			minLength = stringSpec.minLength;

		if (type(stringSpec.maxLength) == "int")
			maxLength = stringSpec.maxLength;

		return random_value(stringSpec.format, minLength, maxLength);
	},

	emit_number: function(numberSpec)
	{
		assert(numberSpec.type == "integer", "Expecting number type");

		let rv = this.emit_generic(numberSpec);

		if (rv == rv)
			return rv;

		let multiplicator = 1;

		if (type(numberSpec.default) == "double" ||
		    length(filter(numberSpec.examples, i => type(i) == "double")))
			multiplicator = 0.1;

		if (this.is_number(numberSpec.multipleOf) > 0)
			multiplicator = numberSpec.multipleOf;

		let min = this.is_number(numberSpec.minimum);
		let max = this.is_number(numberSpec.maximum);
		let exMin = this.is_number(numberSpec.exclusiveMinimum);
		let exMax = this.is_number(numberSpec.exclusiveMaximum);

		if (is_array(numberSpec.examples))
			return random_item(numberSpec.examples);

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

		if (is_array(boolSpec.examples))
			return random_item(boolSpec.examples);
		else if (exists(boolSpec, "default"))
			return (boolSpec.default == true);

		return ((math.rand() % 2) == 0);
	},

	emit_spec: function(valueSpec, noExample)
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
			return this.emit_string(valueSpec, noExample);

		case "integer":
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

printf("%.J\n", document);

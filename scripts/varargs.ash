int sep_length(string sep, boolean encode) {
	return encode? entity_encode(sep).length() : sep.length();
}

string join(string sep, string[int] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach _,it in arr
		if (it.length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, string[int] arr) {
	return sep.join(arr, false);
}

string join(string sep, boolean[string] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach it in arr
		if (it.length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, boolean[string] arr) {
	return sep.join(arr, false);
}

string join(string sep, item[int] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach _,it in arr
		if (it.to_string().length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, item[int] arr) {
	return sep.join(arr, false);
}

string join(string sep, boolean[item] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach it in arr
		if (it.to_string().length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, boolean[item] arr) {
	return sep.join(arr, false);
}

string join(string sep, int[int] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach _,it in arr
		if (it.length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, int[int] arr) {
	return sep.join(arr, false);
}

string join(string sep, boolean[int] arr, boolean encode) {
	if (arr.count() < 1)
		return '';
	buffer o;
	foreach it in arr
		if (it.length() > 0)
			o.append(encode? entity_encode(it + sep) : it + sep);
	o.set_length(o.length() - sep_length(sep, encode));
	return o.to_string();
}
string join(string sep, boolean[int] arr) {
	return sep.join(arr, false);
}

string[string] tokenize(string input, string[string] tokens) {
	matcher m = create_matcher("[-!]?(\\w+)(=(\\w+|\'[^\']*\'|\"[^\"]*\"))?", input);
	// i.e. any formats among `one two=2 three='2' four="2" five="1 2" -six !seven -!eight 9=9`
	while (find(m)) {
		string value, key = group(m, 1);
		if (m.group(2) != "") { // Key has a value assignment
			value = m.group(3);
			if ((value.starts_with("\"") && value.ends_with("\"")) || (value.starts_with("'") && value.ends_with("'"))) {
				value = value.substring(1, length(value) - 1);
			}
		} else
			value = !(m.group(0).starts_with("-") || m.group(0).starts_with("!"));
		tokens[key] = value;
	}
	return tokens;
}

string[string] tokenize(string input) {
	return tokenize(input, string[string]{});
}
string[string] tokenize(string[int] input, string[string] tokens) {
	return tokenize(" ".join(input), tokens);
}
string[string] tokenize(string[int] input) {
	return tokenize(" ".join(input), string[string]{});
}

string get(string[string] map, string key) {
	string retval;
	if (!(map contains key)) {
		print(`settings["{key}"] is unassigned, defaulting to "{retval}"`, "red");
	}
	else {
		retval = map[key];
		if (map[key] == "")
			print(`settings["{key}"] == "", defaulting to "{retval}"`, "red");
	}
	return retval;
}
string get_str(string[string] map, string key) {
	return get(map, key);
}
buffer get_buf(string[string] map, string key) {
	return get(map, key).to_buffer();
}

boolean get_bool(string[string] map, string key) {
	boolean retval;
	if (!(map contains key)) {
		print(`settings["{key}"] is unassigned, defaulting to "{retval}"`, "red");
	}
	else {
		retval = map[key].to_boolean();
		if (map[key] == "")
			print(`settings["{key}"] == "", defaulting to "{retval}"`, "red");
		if (map[key] != retval.to_string())
			print(`settings["{key}"] == "{map[key]}", interpreting as "{retval}"`, "olive");
	}
	return retval;
}

int get_int(string[string] map, string key) {
	int retval;
	if (!(map contains key)) {
		print(`settings["{key}"] is unassigned, defaulting to "{retval}"`, "red");
	}
	else {
		retval = map[key].to_int();
		if (map[key] == "")
			print(`settings["{key}"] == "", defaulting to "{retval}"`, "red");
		if (map[key] != retval.to_string())
			print(`settings["{key}"] == "{map[key]}", interpreting as "{retval}"`, "olive");
	}
	return retval;
}

float get_float(string[string] map, string key) {
	float retval;
	if (!(map contains key))
		print(`settings["{key}"] is unassigned, defaulting to "{retval}"`, "red");
	else {
		retval = map[key].to_float();
		if (map[key] == "")
			print(`settings["{key}"] == "", defaulting to "{retval}"`, "red");
		if (map[key] != retval.to_string())
			print(`settings["{key}"] == "{map[key]}", interpreting as "{retval}"`, "olive");
	}
	return retval;
}

void main(string... args) {
	string[string] settings = tokenize(args, string[string]{
		"bool": "True",
		"int": " -0",
		"float": "+1.05",
		"str": "False",
		"buf": "maybe"
	});
	print(`settings["bool"] == {settings.get_bool("bool")}`);
	print(`settings["int"] == {settings.get_int("int")}`);
	print(`settings["float"] == {settings.get_float("float")}`);
	print(`settings["str"] == {settings.get_str("str")}`);
	print(`settings["buf"] == {settings.get_buf("buf")}`);
	settings.get("void");
}

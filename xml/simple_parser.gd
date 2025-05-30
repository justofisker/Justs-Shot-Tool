class_name SimpleXmlParser extends Object

var parser: XMLParser

func _init() -> void:
	parser = XMLParser.new()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		parser.free()

# Overrides

func open(file: String) -> Error:
	return parser.open(file)

func open_buffer(buffer: PackedByteArray) -> Error:
	return parser.open_buffer(buffer)

func get_node_name() -> String:
	return parser.get_node_name()

func get_node_offset() -> int:
	return parser.get_node_offset()

func skip_section() -> void:
	parser.skip_section()

func seek(offset: int) -> void:
	parser.seek(offset)

func is_empty() -> bool:
	return parser.is_empty()

# New

func get_attribute_value(name: String) -> String:
	for idx in parser.get_attribute_count():
		if parser.get_attribute_name(idx) == name:
			return parser.get_attribute_value(idx)
	push_warning("Couldn't find attribute with name: ", name)
	return ""

func has_attribute_value(name: String) -> bool:
	for idx in parser.get_attribute_count():
		if parser.get_attribute_name(idx) == name:
			return true
	return false

func get_node_data_as_int() -> int:
	var data := parser.get_node_data()
	if data.begins_with("0x"):
		return parser.get_node_data().hex_to_int()
	return parser.get_node_data().to_int()

func get_node_data_as_float() -> float:
	return parser.get_node_data().to_float()

func get_node_data() -> String:
	return parser.get_node_data()

func get_node_data_or_null():
	if parser.get_node_type() == XMLParser.NODE_TEXT:
		return parser.get_node_data()
	else:
		return null

func is_element() -> bool:
	return parser.get_node_type() == XMLParser.NODE_ELEMENT
	
func is_element_end() -> bool:
	return parser.get_node_type() == XMLParser.NODE_ELEMENT_END

func is_text() -> bool:
	return parser.get_node_type() == XMLParser.NODE_TEXT

# Reads
func read() -> void:
	var err := parser.read()
	if err != OK:
		push_error("Error while attempting to parse: ", error_string(err))
		return
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END):
		err = parser.read()
		if err != OK:
			push_error("Error while attempting to parse: ", error_string(err))
			return

func read_whitespace() -> void:
	var err := parser.read()
	if err != OK:
		push_error("Error while attempting to parse: ", error_string(err))
		return
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END || parser.get_node_type() == XMLParser.NODE_TEXT):
		err = parser.read()
		if err != OK:
			push_error("Error while attempting to parse: ", error_string(err))
			return

func read_possible_end() -> bool:
	if parser.read() == ERR_FILE_EOF:
		return false
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END):
		if parser.read() == ERR_FILE_EOF:
			return false
	return true

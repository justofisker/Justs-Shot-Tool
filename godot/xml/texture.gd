class_name XMLTexture extends Resource

var file_name: String
var index: int
var animated: bool = false

static func parse(p: SimpleXmlParser) -> XMLTexture:
	var t := XMLTexture.new()
	
	var offset := p.get_node_offset()
	t.animated = p.get_node_name() == "AnimatedTexture"
	
	p.read()
	while !p.is_element_end():
		if p.is_element():
			match p.get_node_name():
				"File":
					p.read_whitespace()
					t.file_name = p.get_node_data()
				"Index":
					p.read_whitespace()
					t.index = p.get_node_data_as_int()
			p.skip_section()
		p.read()
	
	p.seek(offset)
	return t

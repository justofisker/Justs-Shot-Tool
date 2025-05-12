class_name XmlAnimation extends Resource

var prob: float
var period: int
var id: String

var frames: Array[XMLTexture]
var frame_durations: Array[float]

static func parse(p: SimpleXmlParser) -> XmlAnimation:
	var a := XmlAnimation.new()
	if p.has_attribute_value("id"):
		a.id = p.get_attribute_value("id")
	else:
		a.id = ""
	a.prob = p.get_attribute_value("prob").to_float()
	if p.has_attribute_value("period"):
		a.period = p.get_attribute_value("period").to_int()
	var offset := p.get_node_offset()
	p.read()
	
	while !p.is_element_end():
		match p.get_node_name():
			"Frame":
				var inner_offset := p.get_node_offset()
				a.frame_durations.append(p.get_attribute_value("time").to_float())
				p.read()
				a.frames.append(XMLTexture.parse(p))
				p.seek(inner_offset)
		p.skip_section()
		p.read()
	
	p.seek(offset)
	return a

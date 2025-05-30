class_name XmlAnimation extends Resource

var prob: float
var period: int
var id: String

var frames: Array[XMLTexture]
var frame_durations: Array[float]

static func parse(node: XMLNode) -> XmlAnimation:
	var a := XmlAnimation.new()
	
	a.id = node.attributes.get("id", "")
	a.prob = node.attributes.get("prob", 1.0)
	a.period = node.attributes.get("period", 0)
	
	for frame in node.get_children_by_name("Frame"):
		a.frame_durations.append(frame.attributes.get("time", "").to_float())
		a.frames.append(XMLTexture.parse(frame.get_child_by_name("Texture")))
	

	return a

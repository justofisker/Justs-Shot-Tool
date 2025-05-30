class_name XMLTexture extends Resource

var file_name: String
var index: int
var animated: bool = false

static func parse(node: XMLNode) -> XMLTexture:
	var t := XMLTexture.new()
	
	t.animated = node.name == "AnimatedTexture"
	
	t.file_name = node.get_child_by_name("File").content
	var index := node.get_child_by_name("Index").content
	if index.begins_with("0x"):
		t.index = index.hex_to_int()
	else:
		t.index = index.to_int()
	
	return t

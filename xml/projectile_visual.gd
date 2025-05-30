class_name XMLProjectileVisual extends Resource

var id: String = ""

var texture: XMLTexture = null
var random_textures: Array[XMLTexture] = []
var animation: XmlAnimation = null

var angle_correction: int = 0
var rotation: int = 0

static func parse(p: SimpleXmlParser) -> XMLProjectileVisual:
	var proj := XMLProjectileVisual.new()
	
	proj.id = p.get_attribute_value("id")
	
	var offset := p.get_node_offset()
	p.read()
	
	while !p.is_element_end():
		match p.get_node_name():
			"Texture", "AnimatedTexture":
				proj.texture = XMLTexture.parse(p)
			"RandomTexture":
				var inner_offset := p.get_node_offset()
				p.read()
				while !p.is_element_end():
					proj.random_textures.push_back(XMLTexture.parse(p))
					p.skip_section()
					p.read()
				p.seek(inner_offset)
			"AngleCorrection":
				p.read_whitespace()
				proj.angle_correction = p.get_node_data_as_int()
			"Rotation":
				p.read_whitespace()
				proj.rotation = p.get_node_data_as_int()
			"Animation":
				proj.animation = XmlAnimation.parse(p)
			"Class", "ShadowSize", "Size", "SetStyle", "Presentation", "Labels":
				pass
			_:
				push_error("Unknown property of Projectile: %s" % p.get_node_name())
		p.skip_section()
		p.read()
	
	p.seek(offset)
	return proj

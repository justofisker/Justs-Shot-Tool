extends Node

var sprite_sheet := SpriteSheetDeserializer.open("res://assets/flatbuffer/")

var sheets: Array[RotmgSpriteSheet]
var animated_sprites: Array[RotmgAnimatedSprite]

var objects := Dictionary({}, TYPE_STRING, "", null, TYPE_OBJECT, "Resource", XMLProjectileVisual)

func get_texture(texture: XMLTexture) -> AtlasTexture:
	if !texture:
		return null
	for sheet in sheets:
		if sheet.sprite_sheet_name == texture.file_name:
			for sprite in sheet.sprites:
				if sprite.index == texture.index:
					var atlas = AtlasTexture.new()
					atlas.region = sprite.position
					match sprite.a_id:
						1:
							atlas.atlas = preload("res://assets/sprites/groundTiles.png")
						2:
							atlas.atlas = preload("res://assets/sprites/characters.png")
						4:
							atlas.atlas = preload("res://assets/sprites/mapObjects.png")
						_:
							push_error("Invalid atlas_id: %d" % sprite.a_id)
							return null
					return atlas
	return null

const XML_DIR := "res://assets/xml/"
func parse_projectiles() -> void:
	var dir = DirAccess.open(XML_DIR)
	for file in dir.get_files():
		var p = SimpleXmlParser.new()
		var err = p.open(XML_DIR + file)
		if err != OK:
			push_error("Error while trying to open %s: %s" % [file, error_string(err)])
			continue
		p.read()
		assert(p.is_element())
		if p.get_node_name() != "Objects":
			continue
		
		if !p.read_possible_end():
			continue
			
		while !p.is_element_end():
			if p.has_attribute_value("id"):
				var id := p.get_attribute_value("id")
				
				var offset := p.get_node_offset()
				p.read()
				var object_class : String
				var object_class_set := false
				while !p.is_element_end():
					if p.get_node_name() == "Class":
						p.read_whitespace()
						object_class = p.get_node_data()
						object_class_set = true
						break
					p.skip_section()
					p.read()
				p.seek(offset)
				
				if object_class == "Projectile":
					var proj = XMLProjectileVisual.parse(p)
					objects[id] = proj
			
			p.skip_section()
			if !p.read_possible_end():
				break

func _ready() -> void:
	parse_projectiles()
	var spritesheetf = SpriteSheetDeserializer.open("res://assets/flatbuffer/spritesheetf")
	sheets = spritesheetf.sprite_sheets
	animated_sprites = spritesheetf.animated_sprites

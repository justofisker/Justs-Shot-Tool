extends Node

var objects := Dictionary({}, TYPE_STRING, "", null, TYPE_OBJECT, "Resource", XMLProjectileVisual)
var texture_cache := Dictionary({}, TYPE_OBJECT, "Resource", XMLTexture, TYPE_OBJECT, "AtlasTexture", null)

var sheets : Array
var animated_sprites : Array

signal sprites_loaded()

func get_texture(texture: XMLTexture) -> AtlasTexture:
	if !texture || !sheets:
		return null
	if texture_cache.has(texture):
		return texture_cache[texture]
	for sheet: Dictionary in sheets:
		if sheet["sprite_sheet_name"] == texture.file_name:
			for sprite: Dictionary in sheet["sprites"]:
				if sprite.get("index", 0) == texture.index:
					var atlas = AtlasTexture.new()
					var pos: Dictionary = sprite["position"]
					atlas.region = Rect2(pos["x"], pos["y"], pos["w"], pos["h"])
					match int(sprite["a_id"]):
						2:
							atlas.atlas = characters
						4:
							atlas.atlas = map_objects
						_:
							push_error("Invalid atlas_id: %d" % sprite["a_id"])
							return null
					texture_cache[texture] = atlas
					return atlas
	return null

func parse_projectiles() -> void:
	var xml_dir := "./assets/xml/"
	if OS.get_name() == "macOS" || OS.get_name() == "Web":
		xml_dir = "res://assets/xml/"
	var dir = DirAccess.open(xml_dir)
	for file in dir.get_files():
		var p = SimpleXmlParser.new()
		var err = p.open(xml_dir + file)
		if err != OK:
			push_error("Error while trying to open %s: %s" % [file, error_string(err)])
			continue
		p.read()
		if !p.is_element() || p.get_node_name() != "Objects":
			continue
		
		if !p.read_possible_end():
			continue
			
		while !p.is_element_end():
			if p.has_attribute_value("id"):
				var id := p.get_attribute_value("id")
				
				var offset := p.get_node_offset()
				p.read()
				var object_class := ""
				while !p.is_element_end():
					if p.get_node_name() == "Class":
						p.read_whitespace()
						object_class = p.get_node_data()
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

var characters: Texture2D
var map_objects: Texture2D

func load_images() -> void:
	if OS.has_feature("editor") || OS.get_name() == "macOS" || OS.get_name() == "Web":
		characters = load("res://assets/sprites/characters.png")
		map_objects = load("res://assets/sprites/mapObjects.png")
	else:
		characters = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/characters.png"))
		map_objects = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/mapObjects.png"))

func load_spritesheetf() -> void:
	var spritesheetf = JSON.new()
	var err = spritesheetf.parse(FileAccess.get_file_as_string("res://assets/spritesheetf.json"))
	if err != OK:
		push_error("Failed to load spritesheetf.json line: ", str(spritesheetf.get_error_line()), ": ", spritesheetf.get_error_message())
		return
	sheets = spritesheetf.data["sprites"]
	animated_sprites = spritesheetf.data["animated_sprites"]

var load_img_thread := Thread.new()
var load_spritesheetf_thread := Thread.new()
var parse_proj_thread := Thread.new()

var finished_loading := false
func _process(_delta: float) -> void:
	if finished_loading || load_img_thread.is_alive() || load_spritesheetf_thread.is_alive() || parse_proj_thread.is_alive():
		return
	finished_loading = true
	sprites_loaded.emit()
	print("Finished loading sprites")

func _ready() -> void:
	load_img_thread.start(load_images)
	load_spritesheetf_thread.start(load_spritesheetf, Thread.PRIORITY_HIGH)
	parse_proj_thread.start(parse_projectiles)

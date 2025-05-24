extends Node

const ShooterObject = preload("res://bullet_area/shooter_object.gd")

func get_scene_xml() -> String:
	var out := ""
	
	out += "<!---\n"
	out += "\tThis is NOT the same format as your object file!!!\n"
	out += "\tThis is a special format for the shot visualizer tool scenes!\n"
	out += "\tProjectile & Subattack XML can be copied from this file\n"
	out += "-->\n"
	out += "<Objects>\n"
	
	for object: ShooterObject in Bridge.object_container.get_children():
		out += "\t<Object id=\"" + object.object_settings.id + "\">\n"
		out += object.object_settings.to_xml().indent("\t\t")
		for idx in object.projectiles.size():
			out += object.projectiles[idx].to_xml(idx).indent("\t\t")
		for idx in object.attacks.size():
			out += object.attacks[idx].to_xml(idx).indent("\t\t")
		out += "\t</Object>\n"
	
	out += "</Objects>\n"
	
	return out

func load_scene_xml(buffer: PackedByteArray) -> void:
	for child in Bridge.object_container.get_children():
		Bridge.object_container.remove_child(child)
	
	var p := SimpleXmlParser.new()
	var err := p.open_buffer(buffer)
	if err != OK:
		push_error("Error while trying to open scene: %s" % error_string(err))
		return
	p.read()
	assert(p.is_element())
	if p.get_node_name() != "Objects":
		return
	
	if !p.read_possible_end():
		return
	
	while !p.is_element_end():
		var object_settings := XMLObjects.ObjectSettings.new()
		var attacks : Array[XMLObjects.Subattack] = []
		var projectiles : Array[XMLObjects.Projectile] = []
		
		object_settings.id = p.get_attribute_value("id")
		
		var offset := p.get_node_offset()
		p.read()
		while !p.is_element_end():
			match p.get_node_name():
				"Projectile":
					projectiles.push_back(parse_projectile(p))
				"Subattack":
					attacks.push_back(parse_attack(p))
				_:
					var property = p.get_node_name().to_snake_case()
					if property in object_settings:
						if p.is_empty():
							set_flag(object_settings, property)
						else:
							p.read_whitespace()
							set_property(object_settings, property, p.get_node_data())
			p.skip_section()
			p.read()

		var shooter = Node2D.new()
		shooter.set_script(ShooterObject)
		shooter.object_settings = object_settings
		shooter.attacks = attacks
		shooter.projectiles = projectiles
		Bridge.object_container.add_child(shooter)

		p.seek(offset)
		p.skip_section()
		if !p.read_possible_end():
			break
	
	Bridge.selected_object = Bridge.object_container.get_child(0)

func parse_projectile(p: SimpleXmlParser) -> XMLObjects.Projectile:
	var proj = XMLObjects.Projectile.new()
	
	var offset := p.get_node_offset()
	
	p.read()
	
	while !p.is_element_end():
		var property = p.get_node_name().to_snake_case()
		if property in proj:
			if p.is_empty():
				set_flag(proj, property)
			else:
				p.read_whitespace()
				if p.is_element_end():
					p.seek(p.get_node_offset() - 1)
					set_property(proj, property, "")
				else:
					set_property(proj, property, p.get_node_data())
		
		p.skip_section()
		p.read()
	
	p.seek(offset)
	
	return proj

func parse_attack(p: SimpleXmlParser) -> XMLObjects.Subattack:
	var attack = XMLObjects.Subattack.new()
	
	var offset := p.get_node_offset()
	
	set_property(attack, "projectile_id", p.get_attribute_value("projectileId"))
	
	p.read()
	
	while !p.is_element_end():
		var property = p.get_node_name().to_snake_case()
		if property in attack:
			if p.is_empty():
				set_flag(attack, property)
			else:
				p.read_whitespace()
				if p.is_element_end():
					p.seek(p.get_node_offset() - 1)
					set_property(attack, property, "")
				else:
					set_property(attack, property, p.get_node_data())
		
		p.skip_section()
		p.read()
	
	p.seek(offset)
	
	return attack

func set_property(object: Object, property: String, value: String) -> void:
	if value.contains(","):
		var set_value := Vector2.ZERO
		var parts = value.split(",")
		set_value.x = float(parts[0])
		set_value.y = float(parts[1])
		object.set(property, set_value)
	elif value.is_valid_int():
		object.set(property, int(value))
	elif value.is_valid_float():
		object.set(property, float(value))
	else:
		object.set(property, value)

func set_flag(object: Object, property: String) -> void:
	object.set(property, true)

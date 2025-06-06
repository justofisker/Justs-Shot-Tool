extends Node

func get_scene_xml() -> String:
	var out := ""
	
	out += "<!---\n"
	out += "\tThis is NOT the same format as your object file!!!\n"
	out += "\tThis is a format for the shot visualizer tool scenes!\n"
	out += "\tProjectile & Subattack code can be copied from this file.\n"
	out += "-->\n"
	out += "<Objects>\n"
	
	for object: ShooterObject in Bridge.object_container.get_children():
		out += "\t<Object id=\"" + object.object_settings.id + "\" type=\"" + "0x%x" % object.object_settings.type + "\">\n"
		out += object.object_settings.to_xml().indent("\t\t")
		for idx in object.projectiles.size():
			out += object.projectiles[idx].to_xml(idx).indent("\t\t")
		for idx in object.attacks.size():
			out += object.attacks[idx].to_xml(idx).indent("\t\t")
		for bulltcreate in object.bulletcreates:
			out += bulltcreate.to_xml(0).indent("\t\t")
		out += "\t</Object>\n"
	
	out += "</Objects>\n"
	
	return out

func load_scene_xml(buffer: PackedByteArray) -> void:
	Bridge.clear_objects()
	Bridge.clear_projectiles()
	
	var xml := XML.parse_buffer(buffer)
	
	for object in xml.root.get_children_by_name("Object"):
		var projectiles: Array[XMLObjects.Projectile] = []
		var subattacks: Array[XMLObjects.Subattack] = []
		var bulletcreates: Array[XMLObjects.BulletCreate] = []
		
		for projectile: XMLNode in object.get_children_by_name("Projectile"):
			projectiles.push_back(XMLObjects.Projectile.parse(projectile))
		for subattack: XMLNode in object.get_children_by_name("Subattack"):
			subattacks.push_back(XMLObjects.Subattack.parse(subattack))
		var activates : Array[XMLNode]
		activates.append_array(object.get_children_by_name("OnPlayerShootActivate"))
		activates.append_array(object.get_children_by_name("OnPlayerHitActivate"))
		activates.append_array(object.get_children_by_name("OnPlayerAbilityActivate"))
		activates.append_array(object.get_children_by_name("Activate"))
		for activate in activates:
			bulletcreates.push_back(XMLObjects.BulletCreate.parse(activate))
		
		var object_settings := XMLObjects.ObjectSettings.new()
		object_settings.id = object.attributes.get("id", "")
		object_settings.type = object.attributes.get("type", "0x0").hex_to_int()
		for child: XMLNode in object.children:
			var property = child.name.to_snake_case()
			if property in object_settings:
				if child.content == "":
					set_flag(object_settings, property)
				else:
					set_property(object_settings, property, child.content)
		
		var shooter := ShooterObject.new()
		shooter.object_settings = object_settings
		shooter.projectiles = projectiles
		shooter.attacks = subattacks
		shooter.bulletcreates = bulletcreates
		Bridge.object_container.add_child(shooter)
	
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

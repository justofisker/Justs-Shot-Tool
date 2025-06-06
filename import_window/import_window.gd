extends Window

var root : XMLNode

@export var object_list: VBoxContainer

var object_indices : PackedInt32Array = []

func open_file(data: PackedByteArray) -> void:
	var doc = XML.parse_buffer(data)
	if doc.root.name != "Objects":
		return
	root = doc.root
	for idx in doc.root.children.size():
		var object : XMLNode = doc.root.children[idx]
		var id = object.attributes.get("id")
		var type = object.attributes.get("type", "0x0").hex_to_int()
		var obj_class = object.get_child_by_name("Class")
		if !obj_class || (obj_class.content != "Character" && obj_class.content != "Equipment"):
			continue
		var checkbox := CheckBox.new()
		checkbox.text = "%s [0x%x]" % [ id, type ]
		checkbox.name = str(type)
		object_indices.push_back(idx)
		object_list.add_child(checkbox)

func _ready() -> void:
	close_requested.connect(_on_closed_requested)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()

func _on_closed_requested() -> void:
	queue_free()

func _on_submit_pressed() -> void:
	for idx in object_list.get_child_count():
		var child : CheckBox = object_list.get_child(idx)
		if child.button_pressed:
			var node := root.get_child_by_idx(object_indices[idx])
			var subattacks : Array[XMLObjects.Subattack] = []
			var base_attack := XMLObjects.Subattack.parse(node)
			if node.get_children_by_name("Subattack").size() == 0:
				subattacks.push_back(base_attack)
			for attack: XMLNode in node.get_children_by_name("Subattack"):
				subattacks.push_back(XMLObjects.Subattack.parse(attack, base_attack))
			var projectiles : Array[XMLObjects.Projectile] = []
			for projectile: XMLNode in node.get_children_by_name("Projectile"):
				projectiles.push_back(XMLObjects.Projectile.parse(projectile))
			var bulletcreates : Array[XMLObjects.BulletCreate] = []
			var activates : Array[XMLNode]
			activates.append_array(node.get_children_by_name("OnPlayerShootActivate"))
			activates.append_array(node.get_children_by_name("OnPlayerHitActivate"))
			activates.append_array(node.get_children_by_name("OnPlayerAbilityActivate"))
			activates.append_array(node.get_children_by_name("Activate"))
			var shooter = ShooterObject.new()
			shooter.object_settings.id = node.attributes.get("id")
			shooter.object_settings.type = node.attributes.get("type", "0x0").hex_to_int()
			shooter.attacks = subattacks
			shooter.projectiles = projectiles
			shooter.bulletcreates = bulletcreates
			
			var bcbase := XMLObjects.BulletCreate.new()
			bcbase.type = shooter.object_settings.type
			for activate: XMLNode in activates:
				if activate.content == "BulletCreate":
					bulletcreates.push_back(XMLObjects.BulletCreate.parse(activate, bcbase))
			Bridge.object_container.add_child(shooter)
	queue_free()

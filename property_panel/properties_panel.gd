extends PanelContainer

@export var object_properties_panel : Control
@export var attacks_container : Control
@export var projectiles_container : Control
@export var subattacks_title: Control
@export var projectiles_title: Control

const PROPERTY_INSPECTOR = preload("res://property_panel/property_inspector.tscn")
const ATTACK_PROPERTIES = preload("res://property_panel/attack_properties.tscn")
const PROJECTILE_PROPERTIES = preload("res://property_panel/projectile_properties.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().gui_release_focus()

func _ready() -> void:
	Bridge.property_inspector = self
	Bridge.object_selected.connect(_on_object_selected)
	attacks_container.child_order_changed.connect(_on_reorder_attacks)
	projectiles_container.child_order_changed.connect(_on_reorder_projectiles)

func _on_reorder_attacks() -> void:
	if Bridge.selected_object:
		var attacks : Array[XMLObjects.Subattack] = []
		for attack in attacks_container.get_children():
			attacks.push_back(attack.value)
		Bridge.selected_object.attacks = attacks

func _on_reorder_projectiles() -> void:
	if Bridge.selected_object:
		var projectiles : Array[XMLObjects.Projectile] = []
		for proj in projectiles_container.get_children():
			projectiles.push_back(proj.value)
		Bridge.selected_object.projectiles = projectiles

func _on_object_selected(_old_object: Node2D, object: Node2D) -> void:
	if object:
		object_properties_panel.visible = true
		attacks_container.visible = true
		projectiles_container.visible = true
		subattacks_title.visible = true
		projectiles_title.visible = true
		object_properties_panel.value = object.object_settings
		
		attacks_container.set_block_signals(true)
		projectiles_container.set_block_signals(true)
		
		if attacks_container.get_child_count() != 0:
			for _i in maxi(attacks_container.get_child_count() - object.attacks.size(), 0):
				attacks_container.remove_child(attacks_container.get_child(-1))
		if projectiles_container.get_child_count() != 0:
			for _i in maxi(projectiles_container.get_child_count() - object.projectiles.size(), 0):
				projectiles_container.remove_child(projectiles_container.get_child(-1))
		
		for idx in object.attacks.size():
			if attacks_container.get_child_count() < idx + 1:
				var prop = PROPERTY_INSPECTOR.instantiate()
				prop.properties_scene = ATTACK_PROPERTIES
				prop.value = object.attacks[idx]
				attacks_container.add_child(prop)
			else:
				var prop = attacks_container.get_child(idx)
				prop.value = object.attacks[idx]
				prop.visible = true
		for idx in object.projectiles.size():
			if projectiles_container.get_child_count() < idx + 1:
				var prop = PROPERTY_INSPECTOR.instantiate()
				prop.properties_scene = PROJECTILE_PROPERTIES
				prop.value = object.projectiles[idx]
				projectiles_container.add_child(prop)
			else:
				var prop := projectiles_container.get_child(idx)
				prop.value = object.projectiles[idx]
				prop.visible = true
			
		attacks_container.set_block_signals(false)
		projectiles_container.set_block_signals(false)
	else:
		for child in attacks_container.get_children():
			child.visible = false
		for child in projectiles_container.get_children():
			child.visible = false
		object_properties_panel.visible = false
		attacks_container.visible = false
		projectiles_container.visible = false
		subattacks_title.visible = false
		projectiles_title.visible = false

func _on_add_subattack_pressed() -> void:
	var object = Bridge.selected_object
	if attacks_container.get_child_count() < object.attacks.size() + 1:
		var prop = PROPERTY_INSPECTOR.instantiate()
		prop.properties_scene = ATTACK_PROPERTIES
		prop.value = XMLObjects.Subattack.new()
		attacks_container.add_child(prop)
	else:
		var prop = attacks_container.get_child(object.attacks.size())
		prop.value = XMLObjects.Subattack.new()
		prop.visible = true

func _on_add_projectile_pressed() -> void:
	var object = Bridge.selected_object
	var projectile = XMLObjects.Projectile.new()
	if projectiles_container.get_child_count() < object.projectiles.size() + 1:
		var prop = PROPERTY_INSPECTOR.instantiate()
		prop.properties_scene = PROJECTILE_PROPERTIES
		prop.value = projectile
		projectiles_container.add_child(prop)
	else:
		var prop = projectiles_container.get_child(object.projectiles.size())
		prop.value = projectile
		prop.visible = true

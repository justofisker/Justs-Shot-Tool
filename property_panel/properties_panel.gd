extends PanelContainer

@export var object_properties_panel : Control
@export var attacks_container : Control
@export var projectiles_container : Control
@export var subattacks_title: Control
@export var projectiles_title: Control


const ATTACK_PROPERTY = preload("res://property_panel/attack_property.tscn")
const PROJECTILE_PROPERTY = preload("res://property_panel/projectile_property.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().gui_release_focus()

func _ready() -> void:
	Bridge.object_selected.connect(_on_object_selected)
	attacks_container.child_order_changed.connect(_on_reorder_attacks)
	projectiles_container.child_order_changed.connect(_on_reorder_projectiles)

func _on_reorder_attacks() -> void:
	if Bridge.selected_object:
		var attacks : Array[XMLObjects.Subattack] = []
		for attack in attacks_container.get_children():
			attacks.push_back(attack.attack)
		Bridge.selected_object.attacks = attacks

func _on_reorder_projectiles() -> void:
	if Bridge.selected_object:
		var projectiles : Array[XMLObjects.Projectile] = []
		for proj in projectiles_container.get_children():
			projectiles.push_back(proj.projectile)
		Bridge.selected_object.projectiles = projectiles

func _on_object_selected(_old_object: Node2D, object: Node2D) -> void:
	if object:
		object_properties_panel.visible = true
		attacks_container.visible = true
		projectiles_container.visible = true
		subattacks_title.visible = true
		projectiles_title.visible = true
		object_properties_panel.object_settings = object.object_settings
		
		attacks_container.set_block_signals(true)
		projectiles_container.set_block_signals(true)
		
		for child in attacks_container.get_children():
			attacks_container.remove_child(child)
			child.queue_free()
		for child in projectiles_container.get_children():
			projectiles_container.remove_child(child)
			child.queue_free()
		
		for attack in object.attacks:
			var prop = ATTACK_PROPERTY.instantiate()
			prop.attack = attack
			attacks_container.add_child(prop)
		for proj in object.projectiles:
			var prop = PROJECTILE_PROPERTY.instantiate()
			prop.projectile = proj
			projectiles_container.add_child(prop)
			
		attacks_container.set_block_signals(false)
		projectiles_container.set_block_signals(false)
	else:
		for child in attacks_container.get_children():
			child.queue_free()
		for child in projectiles_container.get_children():
			child.queue_free()
		object_properties_panel.visible = false
		attacks_container.visible = false
		projectiles_container.visible = false
		subattacks_title.visible = false
		projectiles_title.visible = false

func _on_add_subattack_pressed() -> void:
	var prop = ATTACK_PROPERTY.instantiate()
	attacks_container.add_child(prop)

func _on_add_projectile_pressed() -> void:
	var prop = PROJECTILE_PROPERTY.instantiate()
	projectiles_container.add_child(prop)

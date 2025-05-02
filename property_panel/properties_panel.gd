extends PanelContainer

@export var object_properties_panel : Control
@export var attack_properties_panel : Control
@export var projectile_properties_panel : Control

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().gui_release_focus()

func _ready() -> void:
	Bridge.object_selected.connect(_on_object_selected)

func _on_object_selected(_old_object: Node2D, object: Node2D) -> void:
	if object:
		object_properties_panel.visible = true
		attack_properties_panel.visible = true
		projectile_properties_panel.visible = true
		object_properties_panel.object_settings = object.object_settings
		attack_properties_panel.attack = object.attack
		projectile_properties_panel.projectile = object.projectile
	else:
		object_properties_panel.visible = false
		attack_properties_panel.visible = false
		projectile_properties_panel.visible = false

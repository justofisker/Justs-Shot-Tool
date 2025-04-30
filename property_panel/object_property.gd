extends VBoxContainer

signal updated()

var object_settings := XMLObjects.ObjectSettings.new() :
	set(value):
		object_settings = value
		if properties:
			for child in properties.get_children():
				var v = object_settings.get(child.name.to_snake_case())
				if v != null:
					child.value = v
				else:
					push_error("Unable to set value for " + child.name)
		object_settings.updated_position.connect(_on_settings_updated)
		object_settings.updated.connect(_on_settings_updated)
		updated.emit()

@onready var collapse: TextureButton = $HBoxContainer/Collapse
@onready var properties: VBoxContainer = $Properties

func _on_settings_updated() -> void:
	for child in properties.get_children():
		var v = object_settings.get(child.name.to_snake_case())
		if v != null:
			child.set_block_signals(true)
			child.value = v
			child.set_block_signals(false)
		else:
			push_error("Unable to set value for " + child.name)

func _ready() -> void:
	for child in properties.get_children():
		child.value_changed.connect(_set_property.bind(child.name.to_snake_case()))
		_set_property(child.value, child.name.to_snake_case())
		child.toggled.connect(_set_enabled.bind(child.name.to_snake_case()))

func _set_property(value, property: String) -> void:
	object_settings.set(property, value)

func _set_enabled(toggled_on: bool, property: String) -> void:
	object_settings.set(property + "_enabled", toggled_on)

func _on_collapse_pressed() -> void:
	properties.visible = !properties.visible

func _on_bullet_area_selected_shooter(node: Node2D) -> void:
	object_settings = node.object_settings

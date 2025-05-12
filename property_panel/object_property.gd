extends VBoxContainer

var object_settings := XMLObjects.ObjectSettings.new() :
	set(value):
		if object_settings.updated.is_connected(_on_settings_updated):
			object_settings.updated.disconnect(_on_settings_updated)
		object_settings = value
		if properties:
			for child in properties.get_children():
				var v = object_settings.get(child.name.to_snake_case())
				if v != null:
					child.set_block_signals(true)
					child.value = v
					child.set_block_signals(false)
				else:
					push_error("Unable to set value for " + child.name)
		object_settings.updated.connect(_on_settings_updated)

@export var properties: VBoxContainer

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
	object_settings.updated.emit()

func _set_enabled(toggled_on: bool, property: String) -> void:
	object_settings.set(property + "_enabled", toggled_on)
	object_settings.updated.emit()

func _on_collapse_pressed() -> void:
	properties.visible = !properties.visible

func _on_copy_button_pressed() -> void:
	pass

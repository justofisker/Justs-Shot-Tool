extends VBoxContainer

@export var properties_scene : PackedScene
@onready var properties_panel : PanelContainer = get_node_or_null("PropertiesPanel")
var properties : VBoxContainer

var ignore_update := false

var value = null :
	set(new_value):
		value = new_value
		if value == null:
			return
		if !value.updated.is_connected(_on_value_updated):
			value.updated.connect(_on_value_updated)
		if properties:
			for child in properties.get_children():
				if child is HSeparator:
					continue
				var v = value.get(child.name.to_snake_case())
				if v != null:
					child.set_block_signals(true)
					child.value = v
					child.set_block_signals(false)
				else:
					push_error("Unable to set value for " + child.name)

func _ready() -> void:
	if !properties_panel:
		# Specifically for Object Inspector
		properties = $Properties
		for child in properties.get_children():
			if child is HSeparator:
				continue
			child.value_changed.connect.call_deferred(_set_property.bind(child.name.to_snake_case()))
			child.toggled.connect.call_deferred(_set_enabled.bind(child.name.to_snake_case()))

func toggle_property_visibility() -> void:
	if properties:
		properties_panel.visible = !properties_panel.visible
	else:
		properties = properties_scene.instantiate()
		properties_panel.add_child(properties)
		properties_panel.visible = true
		for child in properties.get_children():
			if child is HSeparator:
				continue
			child.value_changed.connect.call_deferred(_set_property.bind(child.name.to_snake_case()))
			child.toggled.connect.call_deferred(_set_enabled.bind(child.name.to_snake_case()))
		value = value

func _on_value_updated() -> void:
	# This is mainly for position
	if !ignore_update:
		value = value

func _set_property(new_value, property: String) -> void:
	ignore_update = true
	value.set(property, new_value)
	value.updated.emit()
	ignore_update = false

func _set_enabled(toggled_on: bool, property: String) -> void:
	ignore_update = true
	value.set(property + "_enabled", toggled_on)
	value.updated.emit()
	ignore_update = false

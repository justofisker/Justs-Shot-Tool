extends Node

@export var properties: VBoxContainer

func _ready() -> void:
	get_parent().value_set.connect(_on_value_set)
	for child in properties.get_children():
		if child is HSeparator:
			continue
		child.value_changed.connect(_set_property.bind(child.name.to_snake_case()))
		_set_property(child.value, child.name.to_snake_case())
		child.toggled.connect(_set_enabled.bind(child.name.to_snake_case()))

func _on_value_set(value) -> void:
	if properties:
		for child in properties.get_children():
			if child is HSeparator:
				continue
			var v = get_parent().value.get(child.name.to_snake_case())
			if v != null:
				child.set_block_signals(true)
				child.value = v
				child.set_block_signals(false)
			else:
				push_error("Unable to set value for " + child.name)

func _set_property(value, property: String) -> void:
	var parent := get_parent()
	parent.value.set(property, value)
	parent.value.updated.emit()

func _set_enabled(toggled_on: bool, property: String) -> void:
	var parent := get_parent()
	parent.value.set(property + "_enabled", toggled_on)
	parent.value.updated.emit()

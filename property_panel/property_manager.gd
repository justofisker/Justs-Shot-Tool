extends Node

@export var properties: VBoxContainer

var ignore_update := false

func _ready() -> void:
	_on_value_set(owner.value)
	owner.value_set.connect(_on_value_set)
	for child in properties.get_children():
		if child is HSeparator:
			continue
		child.value_changed.connect.call_deferred(_set_property.bind(child.name.to_snake_case()))
		child.toggled.connect.call_deferred(_set_enabled.bind(child.name.to_snake_case()))

func _on_value_updated() -> void:
	# This is mainly for position
	if !ignore_update:
		_on_value_set(owner.value)

func _on_value_set(value) -> void:
	if !owner.value.updated.is_connected(_on_value_updated):
		owner.value.updated.connect(_on_value_updated)
	for child in properties.get_children():
		if child is HSeparator:
			continue
		var v = owner.value.get(child.name.to_snake_case())
		if v != null:
			child.set_block_signals(true)
			child.value = v
			child.set_block_signals(false)
		else:
			push_error("Unable to set value for " + child.name)

func _set_property(value, property: String) -> void:
	ignore_update = true
	owner.value.set(property, value)
	owner.value.updated.emit()
	ignore_update = false

func _set_enabled(toggled_on: bool, property: String) -> void:
	ignore_update = true
	owner.value.set(property + "_enabled", toggled_on)
	owner.value.updated.emit()
	ignore_update = false

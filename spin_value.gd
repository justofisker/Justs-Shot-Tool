@tool
extends Node

signal value_changed(value: float)

@onready var label: Label = $Label
@onready var spin_box: SpinBox = $SpinBox

var rdy := {}
func _ready() -> void:
	for key in rdy.keys():
		set(key, rdy[key])
	rdy = {}

func _on_spin_box_value_changed(value: float) -> void:
	value_changed.emit(value)

func _get_property_list() -> Array[Dictionary]:
	var props : Array[Dictionary]
	
	if !spin_box:
		return props
	
	props.append({
			"name": "title",
			"type": TYPE_STRING,
	})
	
	var spin_props := spin_box.get_property_list()
	
	var yeag := false
	for i in spin_props.size():
		var prop = spin_props[i]
		if prop["name"] == "Range" && prop["usage"] == PROPERTY_USAGE_CATEGORY:
			yeag = true
		if yeag:
			props.push_back(prop)
	
	return props

func _get(property: StringName) -> Variant:
	if !label || !spin_box:
		return null
	if property == "title":
		return label.text
	else:
		return spin_box.get(property)

func _set(property: StringName, value: Variant) -> bool:
	if !label || !spin_box:
		rdy[property] = value
		return false
	if property == "title":
		label.text = value
		return true
	else:
		spin_box.set(property, value)
		return true

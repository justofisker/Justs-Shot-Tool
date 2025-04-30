@tool
extends HBoxContainer

signal value_changed(value: Vector2)

@onready var x_edit: HBoxContainer = $VBoxContainer/FloatXEdit
@onready var y_edit: HBoxContainer = $VBoxContainer/FloatYEdit
@onready var label: Label = $Title

@export var text : String = "VectorEdit" :
	set(value):
		text = value
		if is_instance_valid(label):
			label.text = text

@export var suffix : String = "" :
	set(value):
		suffix = value
		if is_instance_valid(x_edit):
			x_edit.suffix = suffix
		if is_instance_valid(y_edit):
			y_edit.suffix = suffix

func _ready() -> void:
	label.text = text
	x_edit.suffix = suffix
	y_edit.suffix = suffix

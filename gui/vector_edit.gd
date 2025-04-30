@tool
extends HBoxContainer

signal value_changed(value: Vector2)

@onready var x_edit: HBoxContainer = $VBoxContainer/FloatXEdit
@onready var y_edit: HBoxContainer = $VBoxContainer/FloatYEdit
@onready var label: Label = $Title

@export var value : Vector2 :
	set(value):
		if x_edit:
			x_edit.value = value.x
		if y_edit:
			y_edit.value = value.y
		value_changed.emit(value)
	get():
		return Vector2(x_edit.value, y_edit.value)

@export var text : String = "VectorEdit" :
	set(value):
		text = value
		if label:
			label.text = text

@export var suffix : String = "" :
	set(value):
		suffix = value
		if x_edit:
			x_edit.suffix = suffix
		if y_edit:
			y_edit.suffix = suffix

func _ready() -> void:
	label.text = text
	x_edit.suffix = suffix
	y_edit.suffix = suffix
	x_edit.value = value.x
	x_edit.value = value.x
	x_edit.value_changed.connect(_on_value_changed)
	y_edit.value_changed.connect(_on_value_changed)

func _on_value_changed(_value: float) -> void:
	value_changed.emit(self.value)

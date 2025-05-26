@tool
extends HBoxContainer

signal value_changed(value: Vector2)
signal toggled(toggled_on: bool)

@onready var x_edit: HBoxContainer = $VBoxContainer/FloatXEdit
@onready var y_edit: HBoxContainer = $VBoxContainer/FloatYEdit
@onready var label: Label = $Title

var ready_value : Vector2

@export var value : Vector2 :
	set(value):
		if x_edit:
			x_edit.value = snappedf(value.x, step)
		if y_edit:
			y_edit.value = snappedf(value.y, step)
		if !x_edit || !y_edit:
			ready_value = value
		value_changed.emit(value)
	get():
		if x_edit && y_edit:
			return Vector2(x_edit.value, y_edit.value)
		else:
			return Vector2()

@export var step : float = 0.001
@export var step_modified: float = 1.0

@export var label_override : String = "" :
	set(value):
		label_override = value
		if label:
			if label_override == "":
				label.text = name
			else:
				label.text = label_override

@export var suffix : String = "" :
	set(value):
		suffix = value
		if x_edit:
			x_edit.suffix = suffix
		if y_edit:
			y_edit.suffix = suffix

func _ready() -> void:
	renamed.connect(_on_renamed)
	_on_renamed()
	x_edit.suffix = suffix
	y_edit.suffix = suffix
	x_edit.value_changed.connect(_on_value_changed)
	y_edit.value_changed.connect(_on_value_changed)
	value = ready_value

func _on_renamed() -> void:
	if label_override == "":
		label.text = name
	else:
		label.text = label_override

func _on_value_changed(_value: float) -> void:
	value_changed.emit(self.value)

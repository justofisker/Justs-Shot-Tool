@tool
extends HBoxContainer

signal value_changed(toggled: bool)
signal toggled(toggle_on: bool)

@export var value : bool = false :
	set(new_value):
		value = new_value
		if check_box:
			check_box.button_pressed = value
		value_changed.emit(value)

@export var label_override : String = "" :
	set(value):
		label_override = value
		if label:
			if label_override == "":
				label.text = name
			else:
				label.text = label_override

@onready var check_box: CheckBox = $PanelContainer/CheckBox
@onready var label: Label = $Label

func _ready() -> void:
	renamed.connect(_on_renamed)
	_on_renamed()
	check_box.button_pressed = value

func _on_renamed() -> void:
	if label_override == "":
		label.text = name
	else:
		label.text = label_override

func _on_check_box_toggled(toggled_on: bool) -> void:
	self.value = toggled_on

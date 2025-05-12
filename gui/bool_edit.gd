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

@export var text : String = "BoolEdit" :
	set(value):
		text = value
		if label:
			label.text = value

@onready var check_box: CheckBox = $PanelContainer/CheckBox
@onready var label: Label = $Label

func _ready() -> void:
	label.text = text
	check_box.button_pressed = value

func _on_check_box_toggled(toggled_on: bool) -> void:
	self.value = toggled_on

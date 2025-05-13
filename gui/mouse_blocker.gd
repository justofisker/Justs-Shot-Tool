extends Control

@export var line_edit : LineEdit

enum ValueType { Number, X, Y }
@export var value_type := ValueType.Number

func _ready() -> void:
	line_edit.focus_entered.connect(_line_edit_focus_entered)
	line_edit.focus_exited.connect(_line_edit_focus_exited)

var owner_value :
	set(value):
		match value_type:
			ValueType.Number:
				owner.value = value
			ValueType.X:
				owner.value.x = value
			ValueType.Y:
				owner.value.y = value
	get():
		match value_type:
			ValueType.Number:
				return owner.value
			ValueType.X:
				return owner.value.x
			ValueType.Y:
				return owner.value.y

var grab_value
var grab_origin : Vector2
var pressed := false
var moved := false
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			pressed = true
			moved = false
			grab_value = owner_value
			grab_origin = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if pressed:
			moved = true
		if pressed && moved:
			owner_value = grab_value + max(abs(grab_value), 0.5) * (get_global_mouse_position().x - grab_origin.x) * 0.003
			if event.ctrl_pressed:
				owner_value = round(owner_value)
	if event is InputEventMouseButton:
		if pressed && !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if moved:
				pressed = false
				moved = false
			else:
				line_edit.grab_focus()
				mouse_filter = Control.MOUSE_FILTER_IGNORE

func _line_edit_focus_entered() -> void:
	pressed = false
	moved = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _line_edit_focus_exited() -> void:
	pressed = false
	moved = false
	mouse_filter = Control.MOUSE_FILTER_STOP

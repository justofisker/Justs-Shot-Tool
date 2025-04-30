extends Control

var pressed : bool = false
var has_moved : bool = false
var gave_focus : bool = false

@onready var line_edit: LineEdit = $"../MarginContainer/LineEdit"
@onready var h_slider: HSlider = $"../HSlider"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				pressed = true
				has_moved = false
				gave_focus = false
				set_deferred("mouse_filter", Control.MOUSE_FILTER_IGNORE)
			else:
				if !has_moved:
					gave_focus = true
					line_edit.grab_click_focus()
				pressed = false
	if event is InputEventMouseMotion:
		if pressed:
			has_moved = true
			if !gave_focus:
				gave_focus = true
				h_slider.grab_click_focus()

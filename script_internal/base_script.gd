class_name BaseScript extends Node

func _ready() -> void:
	var window = Window.new()
	window.min_size = Vector2i.ONE * 100
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	
	add_child(window)
	window.show()
	

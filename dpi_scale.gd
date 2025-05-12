extends Node

func _ready() -> void:
	var window := get_window()
	window.content_scale_factor = DisplayServer.screen_get_scale()
	if OS.get_name() != "Web":
		window.position -= Vector2i(window.size * (window.content_scale_factor - 1.0)) / 2
		window.size *= get_window().content_scale_factor
	queue_free()

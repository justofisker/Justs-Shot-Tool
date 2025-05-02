extends Node

func _ready() -> void:
	var window := get_window()
	window.content_scale_factor = maxf(DisplayServer.screen_get_dpi() / 128.0, 1.0)
	window.position -= Vector2i(window.size * (window.content_scale_factor - 1.0)) / 2
	window.size *= get_window().content_scale_factor
	queue_free()

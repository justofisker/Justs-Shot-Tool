extends SubViewport

func _ready() -> void:
	size_changed.connect(_on_size_changed)
	_on_size_changed()

func _on_size_changed() -> void:
	var scale = get_window().content_scale_factor
	size_2d_override = size * scale
	size_2d_override_stretch = true
	

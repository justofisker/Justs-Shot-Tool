extends Control

@export var container : SubViewportContainer
@export var viewport : SubViewport

func _ready() -> void:
	resized.connect(_on_resized)
	container.scale = Vector2.ONE / get_window().content_scale_factor
	_on_resized()

func _on_resized() -> void:
	container.position = global_position
	viewport.size = size * get_window().content_scale_factor
	container.size = size * get_window().content_scale_factor

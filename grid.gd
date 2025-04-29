@tool
extends Control

var tile_scale : float = 32.0 :
	set(value):
		tile_scale = value
		queue_redraw()

const COLOR := Color.DARK_GRAY

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	var y_shift := tile_scale - fmod(size.y, tile_scale * 2) / 2.0
	var x_shift := tile_scale - fmod(size.x, tile_scale * 2) / 2.0
	for i in range(0, size.x, tile_scale):
		draw_line(Vector2(i - x_shift + tile_scale / 2.0, 0), Vector2(i - x_shift + tile_scale / 2.0, size.y), COLOR)
	for i in range(0, size.y, tile_scale):
		draw_line(Vector2(0, i - y_shift+ tile_scale / 2.0), Vector2(size.x, i - y_shift + tile_scale / 2.0), COLOR)

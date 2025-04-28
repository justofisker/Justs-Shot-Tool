@tool
extends Control

const TILE_SCALE : float = 32
const COLOR := Color.DARK_GRAY

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	var y_shift := TILE_SCALE - fmod(size.y, TILE_SCALE * 2) / 2.0
	var x_shift := TILE_SCALE - fmod(size.x, TILE_SCALE * 2) / 2.0
	for i in range(0, size.x, TILE_SCALE):
		draw_line(Vector2(i - x_shift + TILE_SCALE / 2.0, 0), Vector2(i - x_shift + TILE_SCALE / 2.0, size.y), COLOR)
	for i in range(0, size.y, TILE_SCALE):
		draw_line(Vector2(0, i - y_shift+ TILE_SCALE / 2.0), Vector2(size.x, i - y_shift + TILE_SCALE / 2.0), COLOR)

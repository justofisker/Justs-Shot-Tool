extends Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var length = 7
	draw_circle(Vector2(), 3, Color.WHITE, false)
	draw_line(Vector2(), Vector2(0, -length), Color.GREEN, 0.1)
	draw_polygon([Vector2(-1.3, -length), Vector2(0, -length - 2), Vector2(1.3, -length),], [Color.GREEN])
	draw_line(Vector2(), Vector2(length, 0), Color.RED)
	draw_polygon([Vector2(length, 1.3), Vector2(length + 2, 0), Vector2(length, -1.3),], [Color.RED])

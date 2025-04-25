@tool
extends CanvasItem

@export var circle_size : float = 50.0 :
	set(size):
		circle_size = size
		queue_redraw()
@export var segment_count : int = 25 :
	set(count):
		segment_count = count
		queue_redraw()

func _draw() -> void:
	var points : PackedVector2Array = []
	points.push_back(Vector2(1, 0) * circle_size)
	for i in range(1, segment_count):
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
	points.push_back(Vector2(1, 0) * circle_size)
	draw_multiline(points, Color.GREEN)

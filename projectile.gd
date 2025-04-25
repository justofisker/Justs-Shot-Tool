extends Node2D

const TILE_SIZE = 64

@export var circle_size : float = 8.0 :
	set(size):
		circle_size = size
		queue_redraw()
@export var segment_count : int = 8 :
	set(count):
		segment_count = count
		queue_redraw()

var proj: XMLObjects.Projectile
var direction: float = 0

func _ready() -> void:
	get_tree().create_timer(proj.lifetime_ms / 1000.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += Vector2(cos(direction), sin(direction)) * delta * TILE_SIZE * proj.speed / 10.0

func _draw() -> void:
	var points : PackedVector2Array = []
	points.push_back(Vector2(1, 0) * circle_size)
	for i in range(1, segment_count):
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
	points.push_back(Vector2(1, 0) * circle_size)
	draw_multiline(points, Color.DARK_RED)

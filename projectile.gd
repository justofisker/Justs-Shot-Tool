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
var y_offset: float = 1
var inverted: bool = false
@onready var speed := proj.speed
@onready var time_created: int = Time.get_ticks_msec()

func _ready() -> void:
	get_tree().create_timer(proj.lifetime_ms / 1000.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() - time_created > proj.acceleration_delay:
		speed += proj.acceleration * delta
	
	if proj.speed_clamp_enabled:
		if proj.acceleration > 0:
			speed = min(speed, proj.speed_clamp)
		else:
			speed = max(speed, proj.speed_clamp)
			
	position += Vector2(cos(direction), sin(direction)) * delta * TILE_SIZE * speed / 10.0

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var points : PackedVector2Array = []
	points.push_back(Vector2(1, 0) * circle_size)
	for i in range(1, segment_count):
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
		points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
	points.push_back(Vector2(1, 0) * circle_size)
	
	y_offset = sin((Time.get_ticks_msec() - time_created) / 1000.0 * proj.frequency * 2 * PI * 2) * proj.amplitude
	if inverted:
		y_offset = -y_offset
	
	for i in points.size():
		points[i] += Vector2(0, y_offset * TILE_SIZE).rotated(direction)
	
	draw_multiline(points, Color.DEEP_PINK)

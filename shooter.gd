extends Node2D

# User defined
var attack := XMLObjects.Subattack.new() :
	set(value):
		attack = value
		timer.wait_time = 1 / attack.rate_of_fire
var projectile := XMLObjects.Projectile.new()

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)

const Projectile = preload("res://projectile.gd")

var projectiles : Array[Projectile]

var inverted : bool = false
func _shoot() -> void:
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0)
	for i in attack.num_projectiles:
		var node = Projectile.new()
		node.set_script(preload("res://projectile.gd"))
		node.proj = projectile
		node.direction = get_local_mouse_position().angle() - angle_offset + deg_to_rad((i + 0.5) * attack.arc_gap) + deg_to_rad(attack.default_angle)
		node.inverted = inverted
		node._ready()
		inverted = !inverted
		projectiles.push_back(node)
		get_tree().create_timer(projectile.lifetime_ms / 1000.0).timeout.connect(projectiles.erase.bind(node))

func _process(_delta: float) -> void:
	queue_redraw()

var radius : float = 2
var segment_count : int = 11
var tile_scale := 10.0
func _draw() -> void:
	if true:
		var points : PackedVector2Array = []
		points.push_back(Vector2(1, 0) * radius * 2)
		for i in range(1, segment_count):
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * radius * 2)
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * radius * 2)
		points.push_back(Vector2(1, 0) * radius * 2)
		draw_multiline(points, Color.GREEN)
	
	for proj in projectiles:
		var points : PackedVector2Array = []
		points.push_back(Vector2(1, 0) * radius)
		for i in range(1, segment_count):
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * radius)
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * radius)
		points.push_back(Vector2(1, 0) * radius)
		
		var delta = sin(PI / 16) * radius
		var arf = -cos(PI / 16) * radius
		points.push_back(Vector2(arf, delta))
		points.push_back(Vector2(radius / 3, delta))
		points.push_back(Vector2(arf, -delta))
		points.push_back(Vector2(radius / 3, -delta))
		
		# Head
		points.push_back(Vector2(radius, 0))
		points.push_back(Vector2(radius / 3, radius / 2))
		points.push_back(Vector2(radius, 0))
		points.push_back(Vector2(radius / 3, -radius / 2))
		points.push_back(Vector2(radius / 3, -radius / 2))
		points.push_back(Vector2(radius / 3, -delta))
		points.push_back(Vector2(radius / 3, radius / 2))
		points.push_back(Vector2(radius / 3, delta))
		
		for i in points.size():
			points[i] = points[i].rotated(proj.direction) * proj.proj.size / 100.0
			points[i] += (Vector2(proj.position) + Vector2(0, proj.y_offset).rotated(proj.direction))
		
		draw_multiline(points, Color.WHITE)

func _physics_process(delta: float) -> void:
	for proj in projectiles:
		proj._physics_process(delta)

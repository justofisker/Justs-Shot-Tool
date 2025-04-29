extends Node2D

var timer: Timer

func _ready() -> void:
	var timer = Timer.new()
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
		node.proj = proj
		node.direction = get_local_mouse_position().angle() - angle_offset + deg_to_rad((i + 0.5) * attack.arc_gap) + deg_to_rad(attack.default_angle)
		node.inverted = inverted
		node._ready()
		inverted = !inverted
		projectiles.push_back(node)
		get_tree().create_timer(proj.lifetime_ms / 1000.0).timeout.connect(projectiles.erase.bind(node))

func _process(delta: float) -> void:
	queue_redraw()

var radius : float = 8.0
var segment_count : int = 11
var tile_scale := 32.0 :
	set(value):
		tile_scale = value
		radius = value / 4.0
		segment_count = sqrt(radius) * 4
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
			points[i] = points[i].rotated(proj.direction + proj.turn_amount)
			points[i] += (Vector2(proj.position) + Vector2(0, proj.y_offset).rotated(proj.direction)) * tile_scale
		
		draw_multiline(points, Color.WHITE)

func _physics_process(delta: float) -> void:
	for proj in projectiles:
		proj._physics_process(delta)

# Attack

var attack := XMLObjects.Subattack.new()

func _on_num_projectiles_value_changed(value: float) -> void:
	attack.num_projectiles = value

func _on_arc_gap_value_changed(value: float) -> void:
	attack.arc_gap = value

func _on_rate_of_fire_value_changed(value: float) -> void:
	attack.rate_of_fire = value

func _on_pos_offset_x_value_changed(value: float) -> void:
	attack.pos_offset.x = value

func _on_pos_offset_y_value_changed(value: float) -> void:
	attack.pos_offset.y = value

func _on_default_angle_value_changed(value: float) -> void:
	attack.default_angle = value

# Projectile

var proj := XMLObjects.Projectile.new()

func _on_lifetime_ms_value_changed(value: float) -> void:
	proj.lifetime_ms = value

func _on_speed_value_changed(value: float) -> void:
	proj.speed = value

func _on_amplitude_value_changed(value: float) -> void:
	proj.amplitude = value

func _on_frequency_value_changed(value: float) -> void:
	proj.frequency = value

func _on_speed_clamp_value_changed(value: float) -> void:
	proj.speed_clamp = value

func _on_speed_clamp_enabled_toggled(toggled_on: bool) -> void:
	proj.speed_clamp_enabled = toggled_on

func _on_acceleration_value_changed(value: float) -> void:
	proj.acceleration = value

func _on_acceleration_delay_value_changed(value: float) -> void:
	proj.acceleration_delay = value

func _on_wavy_toggled(toggled_on: bool) -> void:
	proj.wavy = toggled_on


func _on_turn_rate_value_changed(value: float) -> void:
	proj.turn_rate = value

func _on_turn_rate_delay_value_changed(value: float) -> void:
	proj.turn_rate_delay = value

func _on_turn_rate_stop_time_value_changed(value: float) -> void:
	proj.turn_rate

func _on_turn_acceleration_value_changed(value: float) -> void:
	proj.turn_accerlation = value

func _on_turn_clamp_enabled_toggled(toggled_on: bool) -> void:
	proj.turn_clamp_enabled = toggled_on

func _on_turn_clamp_value_changed(value: float) -> void:
	proj.turn_clamp = value

func _on_turn_stop_time_value_changed(value: float) -> void:
	proj.turn_stop_time = value

func _on_turn_acceleration_delay_value_changed(value: float) -> void:
	proj.turn_accerlation_delay = value

func _on_circle_turn_delay_value_changed(value: float) -> void:
	proj.circle_turn_delay = value

func _on_circle_turn_angle_value_changed(value: float) -> void:
	proj.circle_turn_angle = value

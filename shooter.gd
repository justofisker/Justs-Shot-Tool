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

const circle_size : float= 8.0
const segment_count : int = 8
const TILE_SIZE: float = 32.0
func _draw() -> void:
	for proj in projectiles:
		var points : PackedVector2Array = []
		points.push_back(Vector2(1, 0) * circle_size)
		for i in range(1, segment_count):
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
			points.push_back(Vector2(cos(PI * 2.0 * i / segment_count), sin(PI * 2.0 * i / segment_count)) * circle_size)
		points.push_back(Vector2(1, 0) * circle_size)
		
		for i in points.size():
			points[i] += (Vector2(proj.position) + Vector2(0, proj.y_offset).rotated(proj.direction)) * TILE_SIZE
		
		draw_multiline(points, Color.DEEP_PINK)

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

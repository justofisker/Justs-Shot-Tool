extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

# User defined
var attack := XMLObjects.Subattack.new()
var projectile := XMLObjects.Projectile.new()
var object_settings := XMLObjects.ObjectSettings.new()

var bullet_id : int = 0

@export var selected : bool = false

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)
	
	position = object_settings.position * 8
	
	object_settings.updated.connect(_on_object_settings_updated)
	attack.updated.connect(_on_attack_updated)
	projectile.updated.connect(_on_projectile_updated)

func _on_object_settings_updated():
	position = object_settings.position * 8
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []
	bullet_id = 0

func _on_attack_updated():
	if !is_equal_approx(timer.wait_time, 1.0 / attack.rate_of_fire):
		timer.start(1.0 / attack.rate_of_fire)
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []
	bullet_id = 0

func _on_projectile_updated():
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []
	bullet_id = 0

const SIMULATION_RATE = 60
func calculate_object_path() -> Array[Curve2D]:
	var projectiles = create_projectiles(true, false)
	if attack.num_projectiles % 2 == 1 && (!is_zero_approx(projectile.amplitude) || projectile.wavy):
		projectiles.append_array(create_projectiles(true, false))
	
	var paths : Array[Curve2D]
	paths.resize(projectiles.size())
	for idx in paths.size():
		projectiles[idx].origin -= position / 8.0
		paths[idx] = Curve2D.new()
	
	for idx in projectiles.size():
		var proj = projectiles[idx]
		for t in projectile.lifetime_ms * SIMULATION_RATE / 1000 + 1:
			paths[idx].add_point(proj.calculate_position(t * 1000 / SIMULATION_RATE))
	
	return paths

func create_projectiles(ignore_mouse: bool, angle_incr : bool = true) -> Array[Projectile]:
	var projectiles : Array[Projectile]
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0 + (default_angle_incr if angle_incr else 0))
	for i in attack.num_projectiles:
		var proj = Projectile.new()
		proj.proj = projectile
		proj.angle = 0.0 if ignore_mouse else get_local_mouse_position().angle()
		proj.origin = position / 8.0 + Vector2(attack.pos_offset.y, attack.pos_offset.x).rotated(proj.angle)
		proj.angle += angle_offset - deg_to_rad((i + 0.5) * attack.arc_gap)
		proj.angle += deg_to_rad(attack.default_angle)
		proj.is_accelerating = !is_zero_approx(projectile.acceleration)
		proj.is_turning = projectile.turn_rate != 0
		proj.is_turning_acceleration = !is_zero_approx(projectile.turn_acceleration)
		proj.is_turning_circled = projectile.circle_turn_angle != 0
		proj.turn_stop_time = (projectile.lifetime_ms if projectile.turn_stop_time == 0 else projectile.turn_stop_time) if projectile.circle_turn_delay == 0 || projectile.circle_turn_angle == 0 else projectile.circle_turn_delay
		proj.turn_rate_phase_available = projectile.lifetime_ms > proj.turn_stop_time
		proj.bullet_id = bullet_id
		bullet_id += 1
		projectiles.push_back(proj)
	return projectiles

var default_angle_incr: int = 0
func _shoot() -> void:
	if attack.default_angle_incr != 0:
		default_angle_incr = ((default_angle_incr + attack.default_angle_incr + attack.default_angle_incr_min) % (attack.default_angle_incr_max - attack.default_angle_incr_min)) - attack.default_angle_incr_min
	else:
		default_angle_incr = 0
	for proj in create_projectiles(object_settings.ignore_mouse):
		get_parent().add_projectile(proj)

func _process(_delta: float) -> void:
	queue_redraw()

var projectile_paths : Array[Curve2D]
func _draw() -> void:
	draw_circle(Vector2(), 4, Color.GREEN if selected else Color.WHITE, false)
	
	if object_settings.show_path:
		var rot = 0.0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		rot += deg_to_rad(default_angle_incr)
		draw_set_transform(Vector2.ZERO, rot, Vector2(8, 8))
		for path in projectile_paths:
			draw_polyline(path.get_baked_points(), Color.BLACK)

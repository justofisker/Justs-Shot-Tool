extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

# User defined
var attack := XMLObjects.Subattack.new()
var projectile := XMLObjects.Projectile.new()
var object_settings := XMLObjects.ObjectSettings.new()

@export var selected : bool = false

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)
	
	position = object_settings.position
	
	object_settings.updated.connect(_on_object_settings_updated)
	attack.updated.connect(_on_attack_updated)
	projectile.updated.connect(_on_projectile_updated)

func _on_object_settings_updated():
	position = object_settings.position
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []

func _on_attack_updated():
	if !is_equal_approx(timer.wait_time, 1.0 / attack.rate_of_fire):
		timer.start(1.0 / attack.rate_of_fire)
	inverted = false
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []

func _on_projectile_updated():
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []

const SIMULATION_RATE = 60
func calculate_object_path() -> Array[Curve2D]:
	var projectiles = create_projectiles(true, false)
	if attack.num_projectiles % 2 == 1 && (!is_zero_approx(projectile.amplitude) || projectile.wavy):
		projectiles.append_array(create_projectiles(true, false))
	
	var paths : Array[Curve2D]
	paths.resize(projectiles.size())
	for idx in paths.size():
		paths[idx] = Curve2D.new()
	
	for idx in projectiles.size():
		var proj = projectiles[idx]
		paths[idx].add_point(proj.origin + proj.position)
		for t in projectile.lifetime_ms * SIMULATION_RATE / 1000:
			projectiles[idx]._physics_process(1.0 / SIMULATION_RATE)
			paths[idx].add_point(proj.origin + proj.position + Vector2(0, proj.y_offset).rotated(proj.direction))
	
	return paths

func create_projectiles(ignore_mouse: bool, angle_incr : bool = true) -> Array[Projectile]:
	var projectiles : Array[Projectile]
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0 + (default_angle_incr if angle_incr else 0))
	for i in attack.num_projectiles:
		var proj = Projectile.new()
		proj.proj = projectile
		proj.direction = 0.0 if ignore_mouse else get_local_mouse_position().angle()
		proj.direction += -angle_offset + deg_to_rad((i + 0.5) * attack.arc_gap) - deg_to_rad(attack.default_angle)
		proj.inverted = inverted
		proj.origin = to_global(Vector2(attack.pos_offset.y, attack.pos_offset.x).rotated(proj.direction))
		proj._ready()
		inverted = !inverted
		projectiles.push_back(proj)
	return projectiles

var default_angle_incr: int = 0
var inverted : bool = false
func _shoot() -> void:
	if attack.default_angle_incr != 0:
		default_angle_incr = posmod(default_angle_incr + attack.default_angle_incr + attack.default_angle_incr_min, attack.default_angle_incr_max - attack.default_angle_incr_min) - attack.default_angle_incr_min
	else:
		default_angle_incr = 0
	for proj in create_projectiles(object_settings.ignore_mouse):
		get_parent().projectiles.push_back(proj)
		get_tree().create_timer(projectile.lifetime_ms / 1000.0).timeout.connect(get_parent().projectiles.erase.bind(proj))

func _process(_delta: float) -> void:
	queue_redraw()

var radius : float = 5
var projectile_paths : Array[Curve2D]
func _draw() -> void:
	draw_circle(Vector2(), radius, Color.GREEN if selected else Color.WHITE, false)
	
	if object_settings.show_path:
		var rot = 0.0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		rot -= deg_to_rad(default_angle_incr)
		draw_set_transform(Vector2(), rot)
		for path in projectile_paths:
			draw_polyline(path.get_baked_points(), Color.BLACK)

extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

# User defined
var attacks : Array[XMLObjects.Subattack] = [ XMLObjects.Subattack.new() ] :
	set(value):
		attacks = value
		reset()
var projectiles : Array[XMLObjects.Projectile] = [ XMLObjects.Projectile.new() ] :
	set(value):
		projectiles = value
		reset()
var object_settings := XMLObjects.ObjectSettings.new()

var bullet_id : int = 0

@export var selected : bool = false

var timer: Timer

func calculate_shots_per_sec() -> float:
	return 2
	#return (1.5 + 6.5 * (object_settings.dexterity / 75.0)) * attack.rate_of_fire

func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1.0 / calculate_shots_per_sec()
	timer.timeout.connect(_shoot)
	add_child(timer)
	
	position = object_settings.position * 8
	
	object_settings.updated.connect(_on_object_settings_updated)
	for attack in attacks:
		attack.updated.connect(reset)
	for projectile in projectiles:
		projectile.updated.connect(reset)

func reset() -> void:
	for attack in attacks:
		if !attack.updated.is_connected(reset):
			attack.updated.connect(reset)
	for projectile in projectiles:
		if !projectile.updated.is_connected(reset):
			projectile.updated.connect(reset)
	if object_settings.show_path:
		projectile_paths = calculate_object_path()
	else:
		projectile_paths = []
	bullet_id = 0

func _on_object_settings_updated():
	position = object_settings.position * 8
	reset()

const SIMULATION_RATE = 60
func calculate_object_path() -> Array[Curve2D]:
	var projs : Array[Projectile]
	for attack in attacks:
		if attack.projectile_id < 0 || attack.projectile_id >= projectiles.size():
			continue
		var projectile := projectiles[attack.projectile_id]
		projs.append_array(create_projectiles(attack, true, false))
		if attack.num_projectiles % 2 == 1 && (!is_zero_approx(projectile.amplitude) || projectile.wavy):
			projs.append_array(create_projectiles(attack, true, false))
	
	var paths : Array[Curve2D]
	paths.resize(projs.size())
	for idx in paths.size():
		projs[idx].origin -= position / 8.0
		paths[idx] = Curve2D.new()
	
	for idx in projs.size():
		var proj = projs[idx]
		proj._ready()
		for t in proj.proj.lifetime_ms * SIMULATION_RATE / 1000 + 1:
			paths[idx].add_point(proj.calculate_position(t * 1000 / SIMULATION_RATE))
	
	return paths

func create_projectiles(attack: XMLObjects.Subattack, ignore_mouse: bool, angle_incr : bool = true) -> Array[Projectile]:
	var projs : Array[Projectile]
	if attack.projectile_id < 0 || attack.projectile_id >= projectiles.size():
		return projs
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0 + (default_angle_incr if angle_incr else 0.0))
	for i in attack.num_projectiles:
		var proj = Projectile.new()
		proj.proj = projectiles[attack.projectile_id]
		proj.angle = 0.0 if ignore_mouse else get_local_mouse_position().angle()
		proj.origin = position / 8.0 + Vector2(attack.pos_offset.y, attack.pos_offset.x).rotated(proj.angle)
		proj.angle += angle_offset - deg_to_rad((i + 0.5) * attack.arc_gap)
		proj.angle += deg_to_rad(attack.default_angle)
		proj.bullet_id = bullet_id
		bullet_id += 1
		projs.push_back(proj)
	return projs

var default_angle_incr: float = 0.0
func _shoot() -> void:
	if !object_settings.autofire && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	#if attack.default_angle_incr != 0:
		#default_angle_incr = fmod((default_angle_incr + attack.default_angle_incr + attack.default_angle_incr_min), (attack.default_angle_incr_max - attack.default_angle_incr_min)) - attack.default_angle_incr_min
	#else:
		#default_angle_incr = 0
	for attack in attacks:
		for proj in create_projectiles(attack, object_settings.ignore_mouse):
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

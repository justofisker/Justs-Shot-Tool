class_name ShooterObject extends Node2D

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
var bulletcreates: Array[XMLObjects.BulletCreate] = [] :
	set(value):
		bulletcreates = value
		reset()

var object_settings := XMLObjects.ObjectSettings.new()

var bullet_id : int = 0

@export var selected : bool = false :
	set(value):
		selected = value
		queue_redraw()

func _ready() -> void:
	position = object_settings.position * 8
	object_settings.updated.connect(_on_object_settings_updated)
	reset()
	Settings.setting_changed.connect(_on_setting_changed)

func _on_setting_changed(property: String) -> void:
	if property == "object_color" || property == "object_selected_color":
		queue_redraw()

var timings : Array[AttackTiming] = []

func reset() -> void:
	queue_redraw()
	timings = []
	for attack in attacks:
		timings.push_back(AttackTiming.new())
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
	var default_angle_incr = 0.0
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0 + (default_angle_incr if angle_incr else 0.0))
	for i in attack.num_projectiles:
		var proj = Projectile.new()
		proj.proj = projectiles[attack.projectile_id]
		proj.angle = 0.0 if ignore_mouse else get_local_mouse_position().angle()
		proj.shoot_angle = 0.0 if ignore_mouse else get_local_mouse_position().angle()
		proj.origin = position / 8.0 + Vector2(attack.pos_offset.y, attack.pos_offset.x).rotated(proj.angle)
		proj.angle += angle_offset - deg_to_rad((i + 0.5) * attack.arc_gap)
		proj.angle += deg_to_rad(attack.default_angle)
		proj.bullet_id = bullet_id
		bullet_id += 1
		projs.push_back(proj)
	return projs

class AttackTiming:
	var burst_period : float = 0
	var last_attack : float = 0
	var burst_count : int = 0
	var default_angle_incr: float = 0.0

func _process(delta: float) -> void:
	if object_settings.show_path:
		queue_redraw()
	
	var is_shooting = object_settings.autofire || (Bridge.bullet_area.pressed && Bridge.tool_mode == Bridge.ToolMode.Aim)
	
	for idx in attacks.size():
		var timing := timings[idx]
		timing.burst_period += delta
		timing.last_attack += delta
	
	if is_shooting:
		for idx in attacks.size():
			var attack := attacks[idx]
			var timing := timings[idx]
			var shots_per_second := (1.5 + 6.5 * (object_settings.dexterity / 75.0)) * attack.rate_of_fire
			var burst_period = lerpf(attack.burst_delay, attack.burst_min_delay, mini(object_settings.dexterity, 75) / 75.0)
			if attack.burst_count > 0:
				if timing.burst_period > burst_period:
					timing.burst_count = 0
					timing.burst_period = 0
				if timing.burst_count >= attack.burst_count && timing.burst_period < burst_period:
					continue
			if timing.last_attack > 1.0 / shots_per_second:
				timing.last_attack = 0
				timing.burst_count += 1
				
				for proj in create_projectiles(attack, object_settings.ignore_mouse):
					get_parent().add_projectile(proj)

var projectile_paths : Array[Curve2D]
func _draw() -> void:
	draw_circle(Vector2(), 4, Settings.object_selected_color if selected else Settings.object_color, false)
	
	if object_settings.show_path:
		var rot = 0.0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		var default_angle_incr := 0.0
		rot += deg_to_rad(default_angle_incr)
		draw_set_transform(Vector2.ZERO, rot, Vector2(8, 8))
		for path in projectile_paths:
			if path.point_count > 2:
				draw_polyline(path.get_baked_points(), Settings.projectile_path_color)

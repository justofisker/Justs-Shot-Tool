class_name ShooterObject extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

signal updated()

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

func copy() -> ShooterObject:
	var dupe = ShooterObject.new()
	var dupe_attacks : Array[XMLObjects.Subattack] = []
	for attack in Bridge.selected_object.attacks:
		dupe_attacks.push_back(attack.copy())
	dupe.attacks = dupe_attacks
	var dupe_projectiles : Array[XMLObjects.Projectile] = []
	for projectile in Bridge.selected_object.projectiles:
		dupe_projectiles.push_back(projectile.copy())
	dupe.projectiles = dupe_projectiles
	var dupe_bulletcreates : Array[XMLObjects.BulletCreate] = []
	for bulletcreate in Bridge.selected_object.bulletcreates:
		dupe_bulletcreates.push_back(bulletcreate.copy())
	dupe.bulletcreates = dupe_bulletcreates
	dupe.object_settings = Bridge.selected_object.object_settings.copy()
	return dupe

var timings : Array[AttackTiming] = []
var timing_bulletcreate: PackedFloat32Array = []

func reset(supress_emit: bool = false) -> void:
	queue_redraw()
	timings = []
	timing_bulletcreate = []
	for attack in attacks:
		timings.push_back(AttackTiming.new())
		if !attack.updated.is_connected(reset.bind(true)):
			attack.updated.connect(reset.bind(true))
	for projectile in projectiles:
		if !projectile.updated.is_connected(reset):
			projectile.updated.connect(reset)
	for bc in bulletcreates:
		timing_bulletcreate.push_back(0.0)
		if !bc.updated.is_connected(reset.bind(true)):
			bc.updated.connect(reset.bind(true))
		var proc := Bridge.get_object(bc.type)
		if proc:
			if !proc.updated.is_connected(reset.bind(true)):
				proc.updated.connect(reset.bind(true))
	if object_settings.show_path:
		calculate_object_path.call_deferred()
	else:
		projectile_paths = []
		bulletcreate_paths = []
	bullet_id = 0
	if !supress_emit:
		updated.emit()

func _on_object_settings_updated():
	position = object_settings.position * 8
	reset()

func calculate_object_path() -> void:
	bullet_id = 0
	var projs : Array[Projectile]
	var indices : PackedInt32Array
	for idx in attacks.size():
		var attack := attacks[idx]
		if attack.projectile_id < 0 || attack.projectile_id >= projectiles.size():
			continue
		var projectile := projectiles[attack.projectile_id]
		projs.append_array(create_projectiles(attack, true, false))
		for _idx in attack.num_projectiles:
			indices.push_back(idx)
		if (is_zero_approx(projectile.amplitude) || is_zero_approx(projectile.frequency)) && !projectile.wavy:
			continue
		if (attack.num_projectiles % 2 == 0):
			if attacks.size() == 1:
				continue
			# TODO: Figure out if phase can be flipped
		if attack.num_projectiles % 2 == 0:
			bullet_id += 1
		projs.append_array(create_projectiles(attack, true, false))
		for _idx in attack.num_projectiles:
			indices.push_back(idx)
	
	var paths : Array[Curve2D]
	paths.resize(projs.size())
	for idx in paths.size():
		projs[idx].origin -= position / 8.0
		paths[idx] = Curve2D.new()
	
	for idx in projs.size():
		var proj = projs[idx]
		proj.offset = Vector2.ZERO
		proj.origin = Vector2.ZERO
		proj._ready()
		var offset := attacks[indices[idx]].pos_offset
		offset = Vector2(offset.y, offset.x)
		for t in range(0, proj.proj.lifetime_ms, 1000 / Settings.path_simulation_rate):
			paths[idx].add_point(proj.calculate_position(t))
		paths[idx].add_point(proj.calculate_position(proj.proj.lifetime_ms))
	
	var bc_projs: Array[Projectile] = []
	var bc_indices: PackedInt32Array = []
	for idx in bulletcreates.size():
		var bc := bulletcreates[idx]
		var proc := Bridge.get_object(bc.type)
		if !proc || proc.projectiles.size() == 0:
			continue
		var proj := proc.projectiles[0]
		bc_projs.append_array(create_projectiles_bulletcreate(bc, 0.0, false))
		for _i in bc.num_shots:
			bc_indices.push_back(idx)
		if (is_zero_approx(proj.amplitude) || is_zero_approx(proj.frequency)) && !proj.wavy:
			continue
		bc_projs.append_array(create_projectiles_bulletcreate(bc, 0.0, false))
		for _i in bc.num_shots:
			bc_indices.push_back(idx)
	
	var bc_curves: Array[Curve2D] = []
	for proj in bc_projs:
		proj._ready()
		var path := Curve2D.new()
		proj.origin -= position / 8.0
		for t in range(0, proj.proj.lifetime_ms, 1000 / Settings.path_simulation_rate):
			path.add_point(proj.calculate_position(t))
		path.add_point(proj.calculate_position(proj.proj.lifetime_ms))
		bc_curves.push_back(path)
	
	projectile_paths = paths
	projectile_path_attack_indices = indices
	bulletcreate_paths = bc_curves
	bulletcreate_paths_indices = bc_indices

func create_projectiles(attack: XMLObjects.Subattack, ignore_mouse: bool, angle_incr : bool = true) -> Array[Projectile]:
	var angle := 0.0 if ignore_mouse else get_local_mouse_position().angle()
	var projs : Array[Projectile]
	if attack.projectile_id < 0 || attack.projectile_id >= projectiles.size():
		return projs
	var default_angle_incr = timings[attacks.find(attack)].default_angle_incr
	for i in attack.num_projectiles:
		var proj = Projectile.new()
		proj.proj = projectiles[attack.projectile_id]
		proj.angle = angle
		proj.offset = Vector2.from_angle(angle) * 0.5
		proj.origin = position / 8.0 + Vector2(attack.pos_offset.y, attack.pos_offset.x).rotated(proj.angle)
		proj.angle += deg_to_rad(attack.arc_gap * (i - (attack.num_projectiles - 1) / 2.0) + (default_angle_incr if angle_incr else 0.0))
		proj.angle += deg_to_rad(attack.default_angle)
		proj.bullet_id = bullet_id
		bullet_id += 1
		projs.push_back(proj)
	return projs

func create_projectiles_bulletcreate(bc: XMLObjects.BulletCreate, angle: float, use_proc: bool = true) -> Array[Projectile]:
	var projs : Array[Projectile]
	var proc := Bridge.get_object(bc.type)
	if proc == null || proc.projectiles.size() < 1 || (use_proc && randf() > bc.proc) || !bc.enabled:
		return []
	var distance := clampf(get_local_mouse_position().length() / 8.0 if use_proc && !object_settings.ignore_mouse else INF, bc.min_distance, bc.max_distance)
	if !bc.target_mouse:
		distance = 0.0
	
	for i in bc.num_shots:
		var pos = Vector2.ZERO
		if bc.num_shots > 1:
			pos = Vector2(0, bc.gap_tiles * (i - (bc.num_shots - 1) / 2.0)).rotated(deg_to_rad(bc.gap_angle + 90))
		
		var proj = Projectile.new()
		proj.proj = proc.projectiles[0].copy()
		proj.offset = Vector2.ZERO
		proj.proj.size = max(100, proj.proj.size)
		
		var offset_angle := 0.0
		if bc.origin == "target":
			offset_angle += deg_to_rad(bc.offset_angle)
			pos += Vector2(-proj.proj.speed * proj.proj.lifetime_ms / 20000.0, 0).rotated(offset_angle)
		pos.x += distance
		
		proj.angle = angle + offset_angle - deg_to_rad(bc.arc_gap * (i - (bc.num_shots - 1) / 2.0))
		proj.origin = position / 8.0 + pos.rotated(angle)
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
	for idx in bulletcreates.size():
		timing_bulletcreate[idx] = timing_bulletcreate[idx] + delta
	
	var shot_this_frame := false
	
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
				
				shot_this_frame = true
				
				for proj in create_projectiles(attack, object_settings.ignore_mouse):
					get_parent().add_projectile(proj)
				
				if !is_zero_approx(attack.default_angle_incr):
					timing.default_angle_incr = wrapf(timing.default_angle_incr + attack.default_angle_incr, attack.default_angle_incr_min, attack.default_angle_incr_max)
	
	if shot_this_frame:
		var angle := 0.0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		for idx in bulletcreates.size():
			var bc := bulletcreates[idx]
			if !is_zero_approx(bc.cooldown) && bc.cooldown > timing_bulletcreate[idx]:
				continue
			timing_bulletcreate[idx] = 0.0
			for proj in create_projectiles_bulletcreate(bc, angle):
				get_parent().add_projectile(proj)

var projectile_paths: Array[Curve2D]
var projectile_path_attack_indices: PackedInt32Array
var bulletcreate_paths: Array[Curve2D]
var bulletcreate_paths_indices: PackedInt32Array

func _draw() -> void:
	draw_circle(Vector2(), 4, Settings.object_selected_color if selected else Settings.object_color, false)
	
	if object_settings.show_path:
		var rot = 0.0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		for idx in projectile_paths.size():
			var path := projectile_paths[idx]
			if path.point_count < 2:
				continue
			var attack_idx := projectile_path_attack_indices[idx]
			var attack = attacks[attack_idx]
			var default_angle_incr = timings[attack_idx].default_angle_incr
			draw_set_transform_matrix(Transform2D.IDENTITY.translated(Vector2(attack.pos_offset.y + 0.5, attack.pos_offset.x)).scaled(Vector2.ONE * 8).rotated(rot).rotated_local(deg_to_rad(default_angle_incr)))
			draw_polyline(path.get_baked_points(), Settings.projectile_path_color)
		var mouse_distance := INF if object_settings.ignore_mouse else (get_local_mouse_position() / 8.0).length()
		for idx in bulletcreate_paths.size():
			var path := bulletcreate_paths[idx]
			var bc := bulletcreates[bulletcreate_paths_indices[idx]]
			if path.point_count < 2:
				continue
			draw_set_transform_matrix(Transform2D.IDENTITY.scaled(Vector2.ONE * 8.0).rotated(rot).translated_local(Vector2(clampf(mouse_distance, bc.min_distance, bc.max_distance) - bc.max_distance, 0.0)))
			draw_polyline(path.get_baked_points(), Settings.projectile_path_color)

extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

# User defined
var attack := XMLObjects.Subattack.new()
var projectile := XMLObjects.Projectile.new()
var object_settings := XMLObjects.ObjectSettings.new()

@export var selected : bool = false :
	set(value):
		selected = value
		if !selected:
			for child in get_children():
				if child is not Timer:
					remove_child(child)

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

func _on_attack_updated():
	if !is_equal_approx(timer.wait_time, 1.0 / attack.rate_of_fire):
		timer.start(1.0 / attack.rate_of_fire)

func _on_projectile_updated():
	pass

var default_angle_incr: int = 0
var inverted : bool = false
func _shoot() -> void:
	if attack.default_angle_incr != 0:
		default_angle_incr = posmod(default_angle_incr + attack.default_angle_incr + attack.default_angle_incr_min, attack.default_angle_incr_max - attack.default_angle_incr_min) - attack.default_angle_incr_min
	else:
		default_angle_incr = 0
	var angle_offset = deg_to_rad(attack.arc_gap * attack.num_projectiles / 2.0 + default_angle_incr)
	for i in attack.num_projectiles:
		var node = Projectile.new()
		node.set_script(Projectile)
		node.proj = projectile
		node.direction = 0 if object_settings.ignore_mouse else get_local_mouse_position().angle()
		node.direction += -angle_offset + deg_to_rad((i + 0.5) * attack.arc_gap) - deg_to_rad(attack.default_angle)
		node.inverted = inverted
		node.origin = to_global(Vector2(attack.pos_offset).rotated(node.direction))
		node._ready()
		inverted = !inverted
		get_parent().projectiles.push_back(node)
		get_tree().create_timer(projectile.lifetime_ms / 1000.0).timeout.connect(get_parent().projectiles.erase.bind(node))

func _process(_delta: float) -> void:
	queue_redraw()

var radius : float = 5
func _draw() -> void:
	draw_circle(Vector2(), radius, Color.GREEN if selected else Color.WHITE, false)

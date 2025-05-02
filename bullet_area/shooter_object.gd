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

# TODO: Set timer on rate of fire change

var timer: Timer

func _ready() -> void:
	object_settings.position = position
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(_shoot)
	add_child(timer)
	
	object_settings.updated_position.connect(_on_updated_position)
	object_settings.updated.connect(_on_setting_updated)

func _on_updated_position():
	position = object_settings.position

func _on_setting_updated():
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
		%ObjectContainer.projectiles.push_back(node)
		get_tree().create_timer(projectile.lifetime_ms / 1000.0).timeout.connect(%ObjectContainer.projectiles.erase.bind(node))

func _process(_delta: float) -> void:
	queue_redraw()

var radius : float = 5
func _draw() -> void:
	draw_circle(Vector2(), radius, Color.GREEN if selected else Color.WHITE, false)

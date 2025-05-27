extends BaseScript

const info := {
		"name": "Whips",
		"author": "Just",
		"description": "Programmatically create whips."
	}

@export var amount : int = 10
@export var distance : float = 10
@export var travel_time_ms : int = 1000
@export var lifetime_ms : int = 2000
@export var turn_amount : float = 0.0
@export var uniform_speed := false
@export var object_id := "MV Flame Spear"

func run() -> void:
	if travel_time_ms > lifetime_ms:
		travel_time_ms = lifetime_ms
	
	var object := ShooterObject.new()
	
	object.object_settings.dexterity = 0
	
	object.attacks.clear()
	for idx in amount:
		var attack := XMLObjects.Subattack.new()
		attack.projectile_id = idx
		object.attacks.push_back(attack)
	
	object.projectiles.clear()
	for idx in amount:
		var proj := XMLObjects.Projectile.new()
		proj.object_id = object_id
		proj.lifetime_ms = lifetime_ms
		
		var proj_distance : float = (idx + 1) * distance / amount
		if uniform_speed:
			proj.speed = distance / (travel_time_ms / 1000.0) * 10.0
		else:
			proj.speed = proj_distance / (travel_time_ms / 1000.0) * 10.0
		
		if travel_time_ms < lifetime_ms:
			proj.acceleration = -proj.speed * 60
			proj.acceleration_delay = proj_distance / proj.speed * 1000 * 10.0
		
		if !is_zero_approx(turn_amount):
			proj.turn_rate = (idx + 1) * turn_amount / amount
			proj.turn_stop_time = proj_distance / proj.speed * 1000 * 10.0
		
		object.projectiles.push_back(proj)
	
	Bridge.object_container.add_child(object)
	#Bridge.selected_object = object
	

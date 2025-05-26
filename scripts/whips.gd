extends BaseScript

const info := {
		"name": "Whips",
		"author": "Just",
		"description": "Programmatically create whips."
	}

@export var amount : int = 10
@export var distance : float = 10
@export var travel_time_ms : int = 100
@export var lifetime_ms : int = 1000
@export var object_id : String = "MV Flame Spear"

func run() -> void:
	var object := ShooterObject.new()
	
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
		proj.speed = proj_distance / (travel_time_ms / 1000.0) * 10.0
		
		if travel_time_ms < lifetime_ms:
			proj.acceleration = -20000000
			proj.acceleration_delay = travel_time_ms
		
		object.projectiles.push_back(proj)
	
	Bridge.object_container.add_child(object)
	Bridge.selected_object = object
	

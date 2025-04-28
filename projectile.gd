extends Object

var proj: XMLObjects.Projectile
var direction: float = 0
var y_offset: float = 0
var inverted: bool = false
var position: Vector2
var speed : float
var direction_init : float
var time_alive : float = 0
var turn_rate : float
var turn_amount : float

func _ready() -> void:
	speed = proj.speed
	direction_init = direction
	if proj.turn_stop_time > 0:
		turn_rate = proj.turn_rate / ((proj.turn_stop_time - proj.turn_rate_delay) / 1000.0)
	else:
		turn_rate = proj.turn_rate / ((proj.lifetime_ms - proj.turn_rate_delay) / 1000.0)

func _physics_process(delta: float) -> void:
	time_alive += delta
	
	if proj.circle_turn_angle != 0 && time_alive > proj.circle_turn_delay / 1000.0:
		var distance = position.length()
		var angle = position.angle()
		angle += deg_to_rad(delta * proj.circle_turn_angle)
		position = Vector2(distance, 0).rotated(angle)
		return
	
	if time_alive > proj.acceleration_delay / 1000.0:
		speed += proj.acceleration * delta
	
	if proj.speed_clamp_enabled:
		if proj.acceleration > 0:
			speed = min(speed, proj.speed_clamp)
		elif proj.acceleration < 0:
			speed = max(speed, proj.speed_clamp)
	
	if proj.wavy:
		y_offset = sin(time_alive * PI * 6) * time_alive / 2
	elif !is_zero_approx(proj.amplitude):
		y_offset = sin(time_alive * proj.frequency * 2 * PI * 1.75) * proj.amplitude
	
	if inverted:
		y_offset = -y_offset
	
	if proj.turn_rate != 0:
		if proj.turn_rate_delay / 1000.0 <= time_alive:
			if proj.turn_accerlation_delay / 1000.0 <= time_alive:
				turn_rate += proj.turn_accerlation_delay * delta
			turn_amount += turn_rate * delta
			if proj.turn_clamp_enabled:
				turn_amount = clampf(turn_amount, -absf(proj.turn_clamp), absf(proj.turn_clamp))
	
	direction = direction_init + deg_to_rad(turn_amount)
	
	position += Vector2(cos(direction), sin(direction)) * delta * speed / 10.0

extends Object

var proj: XMLObjects.Projectile
var direction: float = 0
var y_offset: float = 0
var inverted: bool = false
var position: Vector2
var speed : float
var direction_init : float
var time_alive : float = 0
var turn_amount : float
var turn_rate : float
var origin : Vector2
var distance_traveled : float

func _ready() -> void:
	speed = proj.speed
	direction_init = direction
	var turn_period = ((proj.turn_stop_time - proj.turn_rate_delay) / 1000.0) if proj.turn_stop_time > 0 else ((proj.lifetime_ms - proj.turn_rate_delay) / 1000.0)
	turn_rate = proj.turn_rate / turn_period

func _physics_process(delta: float) -> void:
	time_alive += delta
	var life_perc = clampf(time_alive / (proj.lifetime_ms / 1000.0), 0, 1)
	
	if time_alive > proj.acceleration_delay / 1000.0:
		speed += proj.acceleration * delta
	
	if proj.speed_clamp_enabled:
		if proj.acceleration > 0:
			speed = min(speed, proj.speed_clamp)
		elif proj.acceleration < 0:
			speed = max(speed, proj.speed_clamp)
	
	if proj.wavy:
		y_offset = sin(time_alive * 3 * 2 * PI) * time_alive * 10
	elif !is_zero_approx(proj.amplitude) && !is_zero_approx(proj.frequency):
		y_offset = sin(life_perc * proj.frequency * 2 * PI ) * proj.amplitude * 10
	
	if inverted:
		y_offset = -y_offset
	
	if proj.turn_rate != 0:
		var turn_period =  ((proj.turn_stop_time - proj.turn_rate_delay) / 1000.0) if proj.turn_stop_time > 0 else ((proj.lifetime_ms - proj.turn_rate_delay) / 1000.0)
		var turn_perc = clampf((time_alive - proj.turn_rate_delay / 1000.0) / turn_period, 0, 1)
		var accel_period = (proj.lifetime_ms- proj.turn_acceleration_delay) / 1000.0
		var accel_perc = clampf((time_alive - proj.turn_acceleration_delay / 1000.0) / accel_period, 0, 1)
		
		turn_amount = lerpf(0, proj.turn_rate, turn_perc)
		
		if proj.turn_clamp_enabled:
			turn_amount = clampf(turn_amount, -absf(proj.turn_clamp), absf(proj.turn_clamp))
		
		#if proj.turn_rate_delay / 1000.0 <= time_alive && (proj.turn_stop_time == 0 || proj.turn_stop_time / 1000.0 >= time_alive):
			#if proj.turn_acceleration_delay / 1000.0 <= time_alive:
				#turn_rate += proj.turn_acceleration * delta
			#turn_amount += turn_rate * delta
	
	
	var old_pos = position
	
	if proj.circle_turn_angle != 0 && time_alive > proj.circle_turn_delay / 1000.0:
		var distance = position.length()
		var angle = position.angle()
		angle -= deg_to_rad(delta * proj.circle_turn_angle)
		position = Vector2(distance, 0).rotated(angle)
		direction = fposmod(direction + deg_to_rad(-proj.circle_turn_angle) * delta, 2 * PI)
		return
	else:
		direction = direction_init + deg_to_rad(turn_amount)
		position += Vector2(cos(direction), sin(direction)) * delta * speed
	
	distance_traveled += (position - old_pos).length()

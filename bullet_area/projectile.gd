extends Object

var proj: XMLObjects.Projectile
var angle: float = 0
var origin : Vector2
var bullet_id = 0
var is_turning : bool = false
var is_turning_circled : bool = false
var turn_rate_phase_available : bool = false
var is_turning_acceleration : bool = false
var is_accelerating : bool = false
var turn_stop_time : int = 0
var time_alive : float = 0

func calculate_position(elapsed: int) -> Vector2:
	var point = origin
	var offset := Vector2.ZERO
	
	var dist = calculate_distance(elapsed)
	var phase = PI if bullet_id % 2 == 0 else 0
	
	if proj.wavy:
		var period_factor = 6.0 * PI
		var amplitude_factor = PI / 64.0
		var theta = angle + amplitude_factor * sin(phase + period_factor * elapsed * 0.001)
		point += Vector2(cos(theta), sin(theta)) * dist
		offset = get_offset(theta)
	elif proj.parametric:
		var t := (float(elapsed) / proj.lifetime_ms) * 2 * PI
		var xt := sin(t) * (1 if bullet_id % 2 > 0 else -1)
		var yt := sin(2 * t) * (1 if bullet_id % 4 < 2 else -1)
		point += Vector2(xt * cos(angle) - yt * sin(angle), xt * sin(angle) + yt * cos(angle)) * proj.speed
		offset = get_offset(angle)
	elif proj.turn_rate != 0:
		var angle_v = 0
		if is_turning_circled && elapsed >= proj.circle_turn_delay:
			dist = calculate_circle_turn_distance()
			angle_v = calculate_circle_turn_angle(elapsed, 0)
		else:
			if elapsed >= turn_stop_time && turn_rate_phase_available:
				point = apply_new_turn_rate_parameters(point)
			
			dist -= turn_distance
			angle_v = calculate_turn(elapsed)
		
		point += Vector2(cos(angle + angle_v), sin(angle + angle_v)) * dist
		offset = get_offset(angle + angle_v)
	elif is_turning_circled:
		var angle_v := 0.0
		if elapsed >= proj.circle_turn_delay:
			dist = calculate_circle_turn_distance()
			angle_v = calculate_circle_turn_angle(elapsed, proj.circle_turn_delay)
		
		point += Vector2(cos(angle + angle_v), sin(angle + angle_v)) * dist
		offset = get_offset(angle + angle_v)
	else:
		if proj.boomerang:
			var halfway = proj.lifetime_ms * proj.speed / 10000.0 / 2.0
			if dist > halfway:
				dist = halfway - (dist - halfway)
		
		point += Vector2(cos(angle), sin(angle)) * dist
		
		if !is_zero_approx(proj.amplitude):
			var deflection = proj.amplitude * sin(phase + (float(elapsed) / proj.lifetime_ms) * proj.frequency * 2 * PI)
			point += Vector2(-sin(angle), cos(angle)) * deflection
		
		offset = get_offset(angle)
	
	return point

func calculate_distance(elapsed: int) -> float:
	var t = elapsed / 1000.0
	var speed_factor = proj.speed / 10.0
	var dist = t * speed_factor
	
	if is_accelerating:
		if elapsed >= proj.acceleration_delay:
			t -= proj.acceleration_delay / 1000.0
			var dv = proj.acceleration * t
			
			if proj.acceleration > 0:
				var max_dv = max(proj.speed_clamp, speed_factor) - speed_factor
				var t_max = max_dv * proj.acceleration
				
				if (t > t_max):
					dist += max_dv * t_max * 0.5
					dist += max_dv * (t - t_max)
				else:
					dist += dv * t * 0.5
			else:
				var min_dv = minf(proj.speed_clamp, speed_factor) - speed_factor
				var t_max2 = min_dv * proj.acceleration
				
				if t > t_max2:
					dist += min_dv * t_max2 * 0.5
					dist += min_dv * (t - t_max2)
				else:
					dist += dv * t * 0.5
	return dist

var circle_distance := 0
func calculate_circle_turn_distance() -> float:
	if circle_distance == 0:
		circle_distance = calculate_distance(proj.circle_turn_delay)
	return circle_distance

func calculate_circle_turn_angle(elapsed: int, delay: int) -> float:
	return deg_to_rad(proj.circle_turn_angle) / turn_stop_time * (elapsed - delay)

var turn_distance : float = 0
func apply_new_turn_rate_parameters(point: Vector2) -> Vector2:
	if !is_turning:
		return point
	
	
	turn_distance = calculate_distance(turn_stop_time)
	var angle_v := calculate_turn(turn_stop_time)
	
	point += Vector2(cos(angle + angle_v), sin(angle + angle_v)) * turn_distance
	
	var next_dist := calculate_distance(turn_stop_time + 16)
	angle_v = calculate_turn(turn_stop_time + 16, true)
	var next_pos := origin + Vector2(cos(angle + angle_v), sin(angle + angle_v)) * next_dist
	
	var dx := next_pos.x - point.x
	var dy := next_pos.y - point.y
	angle = atan2(dy, dx)
	
	origin = point
	is_turning = false
	
	return point

func get_offset(angle: float) -> Vector2:
	return Vector2.ZERO
	#return Vector2(cos(angle), sin(angle))

func calculate_turn(elapsed: int, ignore_lifetime: bool = false) -> float:
	var angle_v := 0.0
	
	if (!ignore_lifetime && elapsed > turn_stop_time):
		return angle_v
	
	var t := elapsed / 1000.0
	
	if proj.turn_rate_delay > 0:
		if elapsed >= proj.turn_rate_delay:
			angle_v = (deg_to_rad(proj.turn_rate) / turn_stop_time) * (elapsed - proj.turn_rate_delay)
			angle_v = add_turn_acceleration(angle_v, t)
	else:
		angle_v = deg_to_rad(proj.turn_rate) / turn_stop_time * elapsed
		angle_v = add_turn_acceleration(angle_v, t)
	
	return angle_v

func add_turn_acceleration(ang: float, t: float) -> float:
	if is_turning_acceleration:
		if t >= proj.turn_acceleration_delay / 1000.0:
			t -= proj.turn_acceleration_delay / 1000.0
			
			var turn_factor := deg_to_rad(proj.turn_rate)
			var dv = proj.turn_acceleration * t
			var max_dv = maxf(deg_to_rad(proj.turn_clamp), turn_factor) - turn_factor
			var t_max = max_dv * proj.turn_acceleration
			
			if proj.turn_acceleration > 0:
				if t > t_max:
					ang += max_dv * t_max * 0.5
					ang += max_dv * (t - t_max)
				else:
					ang += dv * t * 0.5
			else:
				var min_dv = minf(deg_to_rad(proj.turn_clamp), turn_factor) - turn_factor
				var t_max2 = min_dv * proj.turn_acceleration
				
				if t > t_max2:
					ang += min_dv * t_max2 * 0.5
					ang += min_dv * (t - t_max2)
				else:
					ang += dv * t * 0.5
	
	return ang

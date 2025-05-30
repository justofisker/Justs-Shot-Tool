extends Node2D

var proj: XMLObjects.Projectile
var angle: float = 0.0
var shoot_angle: float = 0.0
var origin : Vector2
var bullet_id = 0
@onready var is_turning : bool = proj.turn_rate != 0
@onready var is_turning_circled : bool = proj.circle_turn_delay != 0
var turn_rate_phase_available : bool = false
@onready var is_turning_acceleration : bool = !is_zero_approx(proj.turn_acceleration)
@onready var is_accelerating : bool = !is_zero_approx(proj.acceleration)
var turn_stop_time : int = 0
var circle_turn_stop_time : int = 0
var time_alive : float = 0
var rotation_rate : float = 0
@onready var orig_angle = angle
var offset := Vector2.ZERO

func _ready() -> void:
	if proj.turn_stop_time != 0:
		turn_stop_time = proj.turn_stop_time
	else:
		if proj.circle_turn_delay == 0:
			turn_stop_time = proj.lifetime_ms
		else:
			turn_stop_time = proj.circle_turn_delay
	
	turn_rate_phase_available = turn_stop_time < proj.lifetime_ms
	position = calculate_position(0) * 8.0
	rotation = get_angle(0)

func _draw() -> void:
	if get_child_count() == 0:
		draw_circle(Vector2.ZERO, 1, Settings.projectile_color, false)

func _process(delta: float) -> void:
	time_alive += delta
	var t := roundi(time_alive * 1000)
	if t > proj.lifetime_ms:
		queue_free()
		return
	position = calculate_position(t) * 8.0
	rotation = get_angle(t)
	if !is_zero_approx(rotation_rate):
		rotation += deg_to_rad(rotation_rate) * Time.get_ticks_msec() / 1000.0

func get_angle(elapsed: int) -> float:
	var phase := PI if bullet_id % 2 == 0 else 0.0
	
	if proj.wavy:
		if !proj.face_dir:
			return angle
		var t := elapsed / 1000.0
		var period_factor := 6.0 * PI
		var amplitude_factor := PI / 64.0
		var x := period_factor * amplitude_factor * cos(phase + period_factor * t) * t
		return angle + atan(x)
	elif proj.parametric:
		if !proj.face_dir:
			return angle
		var t := (float(elapsed) / proj.lifetime_ms) * 2 * PI
		var xt := cos(t) * (1 if bullet_id % 2 > 0 else -1)
		var yt := 2 * cos(2 * t) * (1 if bullet_id % 4 < 2 else -1)
		return atan2(xt * sin(angle) + yt * cos(angle), xt * cos(angle) - yt * sin(angle))
	elif is_turning:
		# I don't want to find the derivative of this
		var angle_v := calculate_turn(elapsed)
		var point := -Vector2.from_angle(angle + angle_v) * calculate_distance(elapsed)
		angle_v = calculate_turn(elapsed + 16, true)
		point += Vector2.from_angle(angle + angle_v) * calculate_distance(elapsed + 16)
		return point.angle()
	elif is_turning_circled:
		if elapsed < proj.circle_turn_delay:
			return angle
		var v_angle := calculate_circle_turn_angle(elapsed, proj.circle_turn_delay)
		v_angle += PI / 2 * signf(proj.circle_turn_angle)
		return angle + v_angle
	elif proj.turn_rate == 0:
		if !proj.face_dir:
			return angle
		
		var angle_v := 0.0
		if !is_zero_approx(proj.amplitude):
			var deflection := proj.amplitude * proj.frequency * cos(phase + (float(elapsed) / proj.lifetime_ms) * proj.frequency * 2 * PI)
			angle_v += atan(deflection)
		if proj.boomerang:
			var dist := calculate_distance(elapsed)
			var halfway := proj.lifetime_ms * proj.speed / 10000.0 / 2.0
			if dist > halfway:
				angle_v = PI - angle_v
		
		return angle + angle_v
	return angle

func calculate_position(elapsed: int) -> Vector2:
	var point := origin
	
	var dist := calculate_distance(elapsed)
	var phase := PI if bullet_id % 2 == 0 else 0.0
	
	if proj.wavy:
		var period_factor := 6.0 * PI
		var amplitude_factor := PI / 64.0
		var theta := angle + amplitude_factor * sin(phase + period_factor * elapsed / 1000)
		point += Vector2.from_angle(theta) * dist
	elif proj.parametric:
		var t := (float(elapsed) / proj.lifetime_ms) * 2 * PI
		var xt := sin(t) * (1 if bullet_id % 2 > 0 else -1)
		var yt := sin(2 * t) * (1 if bullet_id % 4 < 2 else -1)
		point += Vector2(xt * cos(angle) - yt * sin(angle), xt * sin(angle) + yt * cos(angle)) * proj.speed
	elif proj.turn_rate != 0:
		var angle_v := 0.0
		if is_turning_circled && elapsed >= proj.circle_turn_delay:
			dist = calculate_circle_turn_distance()
			angle = orig_angle
			angle_v = calculate_circle_turn_angle(elapsed, proj.circle_turn_delay) * proj.turn_rate / proj.circle_turn_angle
			if is_turning:
				angle_v += calculate_turn(turn_stop_time)
		else:
			if elapsed >= turn_stop_time && turn_rate_phase_available:
				point = apply_new_turn_rate_parameters(point)
			
			dist -= turn_distance
			angle_v = calculate_turn(elapsed)
		
		point += Vector2.from_angle(angle + angle_v) * dist
	elif is_turning_circled:
		var angle_v := 0.0
		if elapsed >= proj.circle_turn_delay:
			dist = calculate_circle_turn_distance()
			angle_v = calculate_circle_turn_angle(elapsed, proj.circle_turn_delay)
		
		point += Vector2.from_angle(angle + angle_v) * dist
	else:
		if proj.boomerang:
			var halfway := proj.lifetime_ms * proj.speed / 10000.0 / 2.0
			if dist > halfway:
				dist = halfway - (dist - halfway)
		
		point += Vector2.from_angle(angle) * dist
		
		if !is_zero_approx(proj.amplitude):
			var deflection := proj.amplitude * sin(phase + (float(elapsed) / proj.lifetime_ms) * proj.frequency * 2 * PI)
			point += Vector2(-sin(angle), cos(angle)) * deflection
		
	
	return point + get_offset()

func calculate_distance(elapsed: int) -> float:
	var t := elapsed / 1000.0
	var speed_factor := proj.speed / 10.0
	var dist := t * speed_factor
	
	if is_accelerating:
		if elapsed >= proj.acceleration_delay:
			t -= proj.acceleration_delay / 1000.0
			var dv := proj.acceleration * t / 10.0
			
			if proj.acceleration > 0:
				var max_dv := maxf(proj.speed_clamp / 10.0, speed_factor) - speed_factor
				var t_max := max_dv / proj.acceleration * 10.0
				if (t > t_max):
					dist += max_dv * t_max * 0.5
					dist += max_dv * (t - t_max)
				else:
					dist += dv * t * 0.5
			else:
				var min_dv := minf(proj.speed_clamp / 10.0, speed_factor) - speed_factor
				var t_max := min_dv / proj.acceleration * 10.0
				if t > t_max:
					dist += min_dv * t_max * 0.5
					dist += min_dv * (t - t_max)
				else:
					dist += dv * t * 0.5
	return dist

var circle_distance := 0.0
func calculate_circle_turn_distance() -> float:
	if circle_distance == 0:
		circle_distance = calculate_distance(proj.circle_turn_delay)
	return circle_distance

func calculate_circle_turn_angle(elapsed: int, delay: int) -> float:
	return deg_to_rad(proj.circle_turn_angle) / turn_stop_time * (elapsed - delay)

var turn_distance := 0.0
func apply_new_turn_rate_parameters(point: Vector2) -> Vector2:
	if !is_turning:
		return point
	
	turn_distance = calculate_distance(turn_stop_time)
	var angle_v := calculate_turn(turn_stop_time)
	point += Vector2.from_angle(angle + angle_v) * turn_distance
	
	var next_dist := calculate_distance(turn_stop_time + 16)
	angle_v = calculate_turn(turn_stop_time + 16, true)
	var next_pos := origin + Vector2.from_angle(angle + angle_v) * next_dist
	angle = (next_pos - point).angle()
	
	origin = point
	is_turning = false
	
	return point

func get_offset() -> Vector2:
	if offset.is_zero_approx():
		offset = Vector2(cos(shoot_angle), sin(shoot_angle)) * 0.5
	return offset

func calculate_turn(elapsed: int, ignore_lifetime: bool = false) -> float:
	var angle_v := 0.0
	
	if !ignore_lifetime && elapsed > turn_stop_time:
		return angle_v
	
	if elapsed >= proj.turn_rate_delay:
		angle_v = (deg_to_rad(proj.turn_rate) / turn_stop_time) * (elapsed - proj.turn_rate_delay)
		angle_v = add_turn_acceleration(angle_v, elapsed / 1000.0)
	
	return angle_v

func add_turn_acceleration(ang: float, t: float) -> float:
	if is_turning_acceleration:
		if t >= proj.turn_acceleration_delay / 1000.0:
			t -= proj.turn_acceleration_delay / 1000.0
			
			var turn_factor := deg_to_rad(proj.turn_rate)
			var dv := proj.turn_acceleration * t
			
			if proj.turn_acceleration > 0:
				var max_dv := maxf(deg_to_rad(proj.turn_clamp), turn_factor) - turn_factor
				var t_max := max_dv / proj.turn_acceleration
				if t > t_max:
					ang += max_dv * t_max * 0.5
					ang += max_dv * (t - t_max)
				else:
					ang += dv * t * 0.5
			else:
				var min_dv := minf(deg_to_rad(proj.turn_clamp), turn_factor) - turn_factor
				var t_max := min_dv / proj.turn_acceleration
				if t > t_max:
					ang += min_dv * t_max * 0.5
					ang += min_dv * (t - t_max)
				else:
					ang += dv * t * 0.5
	
	return ang

class_name XMLObjects

class ObjectSettings extends Resource:
	signal updated()
	
	var id: String
	var type: int
	var position : Vector2
	var ignore_mouse : bool = false
	var show_path : bool = false
	var dexterity: int = 45
	
	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> ObjectSettings:
		var out = ObjectSettings.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out

class Subattack extends Resource:
	signal updated()
	
	var projectile_id: int = 0
	var num_projectiles: int = 1
	var rate_of_fire: float = 1
	var pos_offset: Vector2
	var burst_count: int = 1
	var burst_delay: float = 0.0
	var burst_min_delay: float = 0.0
	var arc_gap: int = 0
	var default_angle: int = 0
	var default_angle_incr: int = 0
	var default_angle_incr_max: int = 180
	var default_angle_incr_min: int = -180
	
	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> Subattack:
		var out = Subattack.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out
	
	func to_xml() -> String:
		
		var out = "<Subattack "
		out += "projectileId=\"" + str(projectile_id) + "\">\n"
		
		if num_projectiles != 1:
			out += "\t<NumProjectiles>" + str(num_projectiles) + "</NumProjectiles>\n"
		out += "\t<RateOfFire>" + str(rate_of_fire) + "</RateOfFire>\n"
		out += "\t<Damage>0</Damage>\n"
		if !pos_offset.is_zero_approx():
			out += "\t<PosOffset>" + str(pos_offset.x) + "," + str(pos_offset.y) + "</PosOffset>\n"
		if arc_gap != 0:
			out += "\t<ArcGap>" + str(arc_gap) + "</ArcGap>\n"
		if default_angle != 0:
			out += "\t<DefaultAngle>" + str(arc_gap) + "</DefaultAngle>\n"
		if default_angle_incr != 0:
			out += "\t<DefaultAngleIncr"
			if default_angle_incr_max != 180 || default_angle_incr_min != -180:
				out += " maxAngle=\"%d\" minAngle=\"%d\"" % [ default_angle_incr_max, default_angle_incr_min ]
			out += ">" + str(default_angle_incr) + "</DefaultAngleIncr>\n"
		
		out += "</Subattack>\n"
		
		return out

class ProjectileDescription extends Resource:
	var id: String = ""
	var type: int = 0
	var texture_file: String = "invisible"
	var texture_index: int = 0
	var angle_correction: int = 0 # Sprite orientation is rotated by 45 degrees * AngleCorrection
	var rotation: int = 0
	# TODO: RandomTexture
	
	func to_xml() -> String:
		var out := ""
		
		out += "<Object id=\"" + id + "\" type=\"" + ("0x%x" % type) + "\">\n"
		out += "\t<Class>Projectile</Class>\n"
		out += "\t<Texture>\n"
		out += "\t\t<File>" + texture_file + "</File>\n"
		out += "\t\t<Index>" + ("0x%x" % texture_index) + "</Index>\n"
		out += "\t</Texture>\n"
		
		if angle_correction != 0:
			out += "\t<AngleCorrection>" + str(angle_correction) + "</AngleCorrection>\n"
		if rotation != 0:
			out += "\t<Rotation>" + str(rotation) + "</Rotation>\n"
		
		out += "</Object>\n"
		
		return out

class Projectile extends Resource:
	signal updated()
	
	var id: int = 0
	var object_id: String = ""
	var min_damage: int = 0
	var max_damage: int = 0
	var lifetime_ms: int = 1000
	var size: int = 100 # base 100
	var max_health_damage: float = 0
	var current_health_damage: float = 0
	
	# Speed
	var speed: int = 10
	var speed_clamp_enabled: bool = false
	var speed_clamp: int = 0
	var acceleration: float = 0
	var acceleration_delay: int = 0
	var amplitude: float = 0
	var frequency: float = 0
	
	# Circle Turn
	var circle_turn_delay: int = 0
	var circle_turn_angle: int = 0
	# Turn
	var turn_rate: int = 0
	var turn_rate_delay: int = 0 # ms
	var turn_stop_time: int = 0
	var turn_acceleration: float = 0
	var turn_acceleration_delay: int = 0 # ms
	var turn_clamp_enabled: bool = false
	var turn_clamp: int = 0
	
	# Flags
	var multi_hit: bool = false
	var passes_cover: bool = false
	var armor_piercing: bool = false
	var protect_from_sink: bool = false
	var face_dir: bool = false
	var wavy: bool = false
	var boomerang: bool = false
	var parametric: bool = false
	# Kinda Flag
	var particle_trail: Color = DEFAULT_PARTICLE_TRAIL_COLOR
	const DEFAULT_PARTICLE_TRAIL_COLOR := Color(0xFF00FFFF)
	var particle_trail_enabled: bool = false
	var particle_trail_lifetime_ms : int = 500
	var particle_trail_intensity : float = 1

	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> Projectile:
		var out = Projectile.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out
	
	func to_xml() -> String:
		# General
		var out = "<Projectile id=\"" + str(id) + "\">\n"
		out += "\t<ObjectId>" + object_id + "</ObjectId>\n"
		if size != 100:
			out += "\t<Size>" + str(size) + "</Size>\n"
		
		# Damage
		out += "\t<MinDamage>" + str(min_damage) + "</MinDamage>\n"
		out += "\t<MaxDamage>" + str(max_damage) + "</MaxDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<MaxHealthDamage>" + str(max_health_damage) + "</MaxHealthDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<CurrentHealthDamage>" + str(current_health_damage) + "</CurrentHealthDamage>\n"
		
		# Distance
		out += "\t<LifetimeMS>" + str(lifetime_ms) + "</LifetimeMS>\n"
		out += "\t<Speed>" + str(speed) + "</Speed>\n"
		if speed_clamp_enabled:
			out += "\t<SpeedClamp>" + str(speed_clamp) + "</SpeedClamp>\n"
		if acceleration != 0:
			out += "\t<Acceleration>" + str(acceleration) + "</Acceleration>\n"
		if acceleration_delay != 0:
			out += "\t<AccelerationDelay>" + str(acceleration_delay) + "</AccelerationDelay>\n"
		
		# Sinosoidal
		if !is_equal_approx(amplitude, 0):
			out += "\t<Amplitude>" + str(amplitude) + "</Amplitude>\n"
		if !is_equal_approx(frequency, 0):
			out += "\t<Frequency>" + str(frequency) + "</Frequency>\n"
		if wavy:
			out += "\t<Wavy />\n"
		if parametric:
			out += "\t<Parametric />\n"
		
		# Circle
		if circle_turn_delay != 0:
			out += "\t<CircleTurnDelay>" + str(circle_turn_delay) + "</CircleTurnDelay>\n"
		if circle_turn_angle != 0:
			out += "\t<CircleTurnAngle>" + str(circle_turn_angle) + "</CircleTurnAngle>\n"
		if turn_rate != 0:
			out += "\t<TurnRate>" + str(turn_rate) + "</TurnRate>\n"
		if turn_rate_delay != 0:
			out += "\t<TurnRateDelay>" + str(turn_rate_delay) + "</TurnRateDelay>\n"
		if turn_stop_time != 0:
			out += "\t<TurnStopTime>" + str(turn_stop_time) + "</TurnStopTime>\n"
		if turn_acceleration != 0:
			out += "\t<TurnAcceleration>" + str(turn_acceleration) + "</TurnAcceleration>\n"
		if turn_acceleration_delay != 0:
			out += "\t<TurnAccelerationDelay>" + str(turn_acceleration_delay) + "</TurnAccelerationDelay>\n"
		if turn_clamp_enabled:
			out += "\t<TurnClamp>" + str(turn_clamp) + "</TurnClamp>\n"
		
		# Flags
		if multi_hit:
			out += "\t<MultiHit />\n"
		if passes_cover:
			out += "\t<PassesCover />\n"
		if armor_piercing:
			out += "\t<ArmorPiercing />\n"
		if protect_from_sink:
			out += "\t<ProtectFromSink />\n"
		if face_dir:
			out += "\t<FaceDir />\n"
		if boomerang:
			out += "\t<Boomerang />\n"
		if particle_trail_enabled:
			out += "\t<ParticleTrail"
			if particle_trail != DEFAULT_PARTICLE_TRAIL_COLOR || is_equal_approx(particle_trail_intensity, 1) || particle_trail_lifetime_ms != 500:
				if !is_equal_approx(particle_trail_intensity, 1):
					out += " intensity=\"" + str(particle_trail_intensity) + "\""
				if particle_trail_lifetime_ms != 500:
					out += " lifetimeMS=\"" + str(particle_trail_lifetime_ms) + "\""
				if particle_trail != DEFAULT_PARTICLE_TRAIL_COLOR:
					out += ">0x%06x</ParticleTrail>\n" % (particle_trail.to_rgba32() >> 8)
				else:
					out += "/>\n"
			else:
				out += "/>\n"
		
		out += "</Projectile>\n"
		
		return out

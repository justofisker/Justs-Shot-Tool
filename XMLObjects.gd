class_name XMLObjects extends Resource

class Subattack extends Resource:
	var projectile_id: int = 0
	var num_projectiles: int = 1
	var rate_of_fire: float = 1
	var pos_offset: Vector2i
	var burst_count: int = 1
	var burst_delay: float = 0.0
	var burst_min_delay: float = 0.0
	var arc_gap: int = 0
	var default_angle: int = 0
	var default_angle_incr: int = 0
	var default_angle_incr_max: int = 0
	var default_angle_incr_min: int = 0

	func to_xml() -> String:
		
		var out = "<Subattack "
		out += "projectileId=\"" + str(projectile_id) + "\">\n"
		
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
	var id: int = 0
	var type: int = 0
	var object_id: String = ""
	var min_damage: int = 0
	var max_damage: int = 0
	var lifetime_ms: int = 1000
	var size: int = 100 # base 100
	var max_health_damage: float = 0
	var current_health_damage: float = 0
	
	# Speed
	var speed: int = 100
	var speed_clamp_enabled: bool = false
	var speed_clamp: int = 0
	var acceleration: float = 0
	var acceleration_delay: int = 0
	var amplitude: float = 0
	var frequency: float = 0
	
	# Circle Turn
	var circle_turn_delay = 0
	var circle_turn_angle = 0
	# Turn
	var turn_rate: int = 0
	var turn_rate_delay: int = 0 # ms
	var turn_stop_time: int = 0
	var turn_accerlation: float = 0
	var turn_accerlation_delay: int = 0 # ms
	var turn_clamp_enabled: bool = false
	var turn_clamp: int = 0
	
	# Flags
	var multihit: bool = false
	var passes_cover: bool = false
	var armor_piercing: bool = false
	var protect_from_sink: bool = false
	var face_dir: bool = false
	var wavy: bool = false
	var boomerang: bool = false
	var parametric: bool = false
	# Kinda Flag
	var particle_trail: bool = false
	const DEFAULT_PARTICLE_TRAIL_COLOR: int = 0xFF00FF
	var particle_trail_color: int = DEFAULT_PARTICLE_TRAIL_COLOR
	
	func to_xml() -> String:
		# General
		var out = "<Projectile id=\"" + str(id) + "\">\n"
		out += "\t<ObjectId>" + object_id + "</ObjectId>\n"
		out += "\t<LifetimeMS>" + str(lifetime_ms) + "</LifetimeMS>\n"
		if size != 100:
			out += "\t<Size>" + str(size) + "</Size>\n"
		
		# Damage
		out += "\t<MinDamage>" + str(min_damage) + "</MinDamage>\n"
		out += "\t<MaxDamage>" + str(max_damage) + "</MaxDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<MaxHealthDamage>" + str(max_health_damage) + "</MaxHealthDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<CurrentHealthDamage>" + str(current_health_damage) + "</CurrentHealthDamage>\n"
		
		#var speed_clamp: int = 0
		# Speed
		out += "\t<Speed>" + str(speed) + "</Speed>\n"
		if acceleration != 0:
			out += "\t<Acceleration>" + str(acceleration) + "</Acceleration>\n"
		if acceleration_delay != 0:
			out += "\t<AccelerationDelay>" + str(acceleration_delay) + "</AccelerationDelay>\n"
		if !is_equal_approx(amplitude, 0):
			out += "\t<Amplitude>" + str(amplitude) + "</Amplitude>\n"
		if !is_equal_approx(frequency, 1):
			out += "\t<Frequency>" + str(frequency) + "</Frequency>\n"
		
		# TODO: Turn
		
		# Circle
		if circle_turn_delay != 0:
			out += "\t<CircleTurnDelay>" + str(circle_turn_delay) + "</CircleTurnDelay>\n"
		if circle_turn_angle != 0:
			out += "\t<CircleTurnAngle>" + str(circle_turn_angle) + "</CircleTurnAngle>\n"
		
		# Flags
		if multihit:
			out += "\t<MultiHit />\n"
		if passes_cover:
			out += "\t<PassesCover />\n"
		if armor_piercing:
			out += "\t<ArmorPiercing />\n"
		if protect_from_sink:
			out += "\t<ProtectFromSink />\n"
		if face_dir:
			out += "\t<FaceDir />\n"
		if wavy:
			out += "\t<Wavy />\n"
		if boomerang:
			out += "\t<Boomerang />\n"
		if particle_trail:
			out += "\t<ParticleTrail "
			if particle_trail_color != DEFAULT_PARTICLE_TRAIL_COLOR:
				out += "color=\"" + ("%06x" % particle_trail_color) + "\" "
			out += "/>\n"
		
		out += "</Projectile>\n"
		
		return out

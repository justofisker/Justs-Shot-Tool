class_name XMLObjects

static func float_to_string(a: float) -> String:
	return ("%.3f" % a).trim_suffix("0").trim_suffix("0").trim_suffix(".0")

class ObjectSettings extends Resource:
	signal updated()
	
	var id: String
	var type: int
	var position : Vector2
	var ignore_mouse : bool = false
	var show_path : bool = false
	var dexterity: int = 45
	var autofire : bool = true
	
	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> ObjectSettings:
		var out = ObjectSettings.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out
	
	func float_to_string(a: float) -> String:
		return XMLObjects.float_to_string(a)
	
	func to_xml() -> String:
		var out := ""
		
		out += "<Position>" + float_to_string(position.x) + "," + float_to_string(position.y) + "</Position>\n"
		out += "<Dexterity>" + str(dexterity) + "</Dexterity>\n"
		
		if ignore_mouse:
			out += "<IgnoreMouse />\n"
		if show_path:
			out += "<ShowPath />\n"
		if autofire:
			out += "<Autofire />\n"
		
		return out

class Subattack extends Resource:
	signal updated()
	
	var projectile_id: int = 0
	var num_projectiles: int = 1
	var rate_of_fire: float = 1
	var pos_offset: Vector2
	var burst_count: int = 0
	var burst_delay: float = 1.8
	var burst_min_delay: float = 0.8
	var arc_gap: float = 11.25
	var default_angle: float = 0
	var default_angle_incr: float = 0
	var default_angle_incr_max: float = 180
	var default_angle_incr_min: float = -180
	
	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> Subattack:
		var out = Subattack.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out
	
	func float_to_string(a: float) -> String:
		return XMLObjects.float_to_string(a)
	
	func to_xml(index: int) -> String:
		
		var out = "<Subattack "
		out += "index=\"" + str(index) + "\" "
		out += "projectileId=\"" + str(projectile_id) + "\">\n"
		
		if num_projectiles != 1:
			out += "\t<NumProjectiles>" + str(num_projectiles) + "</NumProjectiles>\n"
		out += "\t<RateOfFire>" + float_to_string(rate_of_fire) + "</RateOfFire>\n"
		if burst_count > 0:
			out += "\t<BurstCount>" + str(burst_count) + "</BurstCount>\n"
			out += "\t<BurstDelay>" + float_to_string(burst_delay) + "</BurstDelay>\n"
			out += "\t<BurstDelayMin>" + float_to_string(burst_min_delay) + "</BurstDelayMin>\n"
		if !pos_offset.is_zero_approx():
			out += "\t<PosOffset>" + float_to_string(pos_offset.x) + "," + float_to_string(pos_offset.y) + "</PosOffset>\n"
		if !is_equal_approx(arc_gap, 11.25):
			out += "\t<ArcGap>" + float_to_string(arc_gap) + "</ArcGap>\n"
		if default_angle != 0:
			out += "\t<DefaultAngle>" + float_to_string(default_angle) + "</DefaultAngle>\n"
		if default_angle_incr != 0:
			out += "\t<DefaultAngleIncr"
			out += " maxAngle=\"%f\" minAngle=\"%f\"" % [ default_angle_incr_max, default_angle_incr_min ]
			out += ">" + float_to_string(default_angle_incr) + "</DefaultAngleIncr>\n"
		
		out += "</Subattack>\n"
		
		return out
		
	static func parse(node: XMLNode, base: XMLObjects.Subattack = XMLObjects.Subattack.new()) -> XMLObjects.Subattack:
		var attack = base.copy()
		
		attack.projectile_id = node.attributes.get("projectileId", 0)
		if node.get_child_by_name("NumProjectiles"):
			attack.num_projectiles = node.get_child_by_name("NumProjectiles").content.to_int()
		if node.get_child_by_name("RateOfFire"):
			attack.rate_of_fire = node.get_child_by_name("RateOfFire").content.to_float()
		var pos_offset_node := node.get_child_by_name("PosOffset")
		if pos_offset_node:
			var s := pos_offset_node.content.split(",")
			if s.size() >= 2:
				attack.pos_offset = Vector2(s[0].to_float(), s[1].to_float())
		if node.get_child_by_name("BurstCount"):
			attack.burst_count = node.get_child_by_name("BurstCount").content.to_int()
		if node.get_child_by_name("BurstDelay"):
			attack.burst_delay = node.get_child_by_name("BurstDelay").content.to_float()
		if node.get_child_by_name("BurstMinDelay"):
			attack.burst_min_delay = node.get_child_by_name("BurstMinDelay").content.to_float()
		if node.get_child_by_name("ArcGap"):
			attack.arc_gap = node.get_child_by_name("ArcGap").content.to_float()
		if node.get_child_by_name("DefaultAngle"):
			attack.default_angle = node.get_child_by_name("DefaultAngle").content.to_float()
		var default_angle_incr_node := node.get_child_by_name("DefaultAngleIncr")
		if default_angle_incr_node:
			attack.default_angle_incr = default_angle_incr_node.content.to_float()
			attack.default_angle_incr_max = default_angle_incr_node.attributes.get("maxAngle", 0)
			attack.default_angle_incr_min = default_angle_incr_node.attributes.get("minAngle", 360)
		
		return attack

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
	
	var object_id: String = ""
	var min_damage: int = 0
	var max_damage: int = 0
	var damage: int = 0
	var lifetime_ms: int = 1000
	var size: int = 100 # base 100
	var max_health_damage: float = 0
	var current_health_damage: float = 0
	
	# Speed
	var speed: float = 10
	var speed_clamp: float = 0
	var acceleration: float = 0
	var acceleration_delay: int = 0
	var amplitude: float = 0
	var frequency: float = 0
	
	# Circle Turn
	var circle_turn_delay: int = 0
	var circle_turn_angle: float = 0
	# Turn
	var turn_rate: float = 0
	var turn_rate_delay: int = 0 # ms
	var turn_stop_time: int = 0
	var turn_acceleration: float = 0
	var turn_acceleration_delay: int = 0 # ms
	var turn_clamp: float = 0
	
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
	
	func float_to_string(a: float) -> String:
		return XMLObjects.float_to_string(a)
	
	func to_xml(index: int) -> String:
		# General
		var out = "<Projectile id=\"" + str(index) + "\">\n"
		out += "\t<ObjectId>" + object_id + "</ObjectId>\n"
		if size != 100:
			out += "\t<Size>" + str(size) + "</Size>\n"
		
		# Damage
		if damage != 0:
			out += "\t<Damage>" + str(damage) + "</Damage>\n"
		elif min_damage == max_damage:
			out += "\t<Damage>" + str(min_damage) + "</Damage>\n"
		else:
			out += "\t<MinDamage>" + str(min_damage) + "</MinDamage>\n"
			out += "\t<MaxDamage>" + str(max_damage) + "</MaxDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<MaxHealthDamage>" + float_to_string(max_health_damage) + "</MaxHealthDamage>\n"
		if !is_zero_approx(max_health_damage):
			out += "\t<CurrentHealthDamage>" + float_to_string(current_health_damage) + "</CurrentHealthDamage>\n"
		
		# Distance
		out += "\t<LifetimeMS>" + str(lifetime_ms) + "</LifetimeMS>\n"
		if parametric:
			out += "\t<Magnitude>" + float_to_string(speed) + "</Magnitude>\n"
		else:
			out += "\t<Speed>" + float_to_string(speed) + "</Speed>\n"
		if acceleration != 0:
			out += "\t<SpeedClamp>" + float_to_string(speed_clamp) + "</SpeedClamp>\n"
			out += "\t<Acceleration>" + float_to_string(acceleration) + "</Acceleration>\n"
		if acceleration_delay != 0:
			out += "\t<AccelerationDelay>" + float_to_string(acceleration_delay) + "</AccelerationDelay>\n"
		
		# Sinosoidal
		if !is_equal_approx(amplitude, 0):
			out += "\t<Amplitude>" + float_to_string(amplitude) + "</Amplitude>\n"
		if !is_equal_approx(frequency, 0):
			out += "\t<Frequency>" + float_to_string(frequency) + "</Frequency>\n"
		if wavy:
			out += "\t<Wavy />\n"
		if parametric:
			out += "\t<Parametric />\n"
		
		# Circle
		if circle_turn_delay != 0:
			out += "\t<CircleTurnDelay>" + str(circle_turn_delay) + "</CircleTurnDelay>\n"
		if circle_turn_angle != 0:
			out += "\t<CircleTurnAngle>" + float_to_string(circle_turn_angle) + "</CircleTurnAngle>\n"
		if turn_rate != 0:
			out += "\t<TurnRate>" + float_to_string(turn_rate) + "</TurnRate>\n"
		if turn_rate_delay != 0:
			out += "\t<TurnRateDelay>" + str(turn_rate_delay) + "</TurnRateDelay>\n"
		if turn_stop_time != 0:
			out += "\t<TurnStopTime>" + str(turn_stop_time) + "</TurnStopTime>\n"
		if turn_acceleration != 0 || turn_acceleration_delay != 0:
			out += "\t<TurnAcceleration>" + float_to_string(turn_acceleration) + "</TurnAcceleration>\n"
			out += "\t<TurnAccelerationDelay>" + str(turn_acceleration_delay) + "</TurnAccelerationDelay>\n"
			out += "\t<TurnClamp>" + float_to_string(turn_clamp) + "</TurnClamp>\n"
		
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
					out += " intensity=\"" + float_to_string(particle_trail_intensity) + "\""
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
	
	static func parse(node: XMLNode, base: XMLObjects.Projectile = XMLObjects.Projectile.new()) -> XMLObjects.Projectile:
		var proj = base.copy()
		
		if node.get_child_by_name("ObjectId"):
			proj.object_id = node.get_child_by_name("ObjectId").content
		if node.get_child_by_name("MinDamage"):
			proj.min_damage = node.get_child_by_name("MinDamage").content.to_int()
		if node.get_child_by_name("MaxDamage"):
			proj.max_damage = node.get_child_by_name("MaxDamage").content.to_int()
		if node.get_child_by_name("Damage"):
			proj.damage = node.get_child_by_name("Damage").content.to_int()
		if node.get_child_by_name("LifetimeMS"):
			proj.lifetime_ms = node.get_child_by_name("LifetimeMS").content.to_int()
		if node.get_child_by_name("Size"):
			proj.size = node.get_child_by_name("Size").content.to_int()
		if node.get_child_by_name("MaxHealthDamage"):
			proj.max_health_damage = node.get_child_by_name("MaxHealthDamage").content.to_float()
		if node.get_child_by_name("CurrentHealthDamage"):
			proj.current_health_damage = node.get_child_by_name("CurrentHealthDamage").content.to_float()
		if node.get_child_by_name("Speed"):
			proj.speed = node.get_child_by_name("Speed").content.to_float()
		if node.get_child_by_name("Magnitude"):
			proj.speed = node.get_child_by_name("Magnitude").content.to_float()
		if node.get_child_by_name("SpeedClamp"):
			proj.speed_clamp = node.get_child_by_name("SpeedClamp").content.to_float()
		if node.get_child_by_name("Acceleration"):
			proj.acceleration = node.get_child_by_name("Acceleration").content.to_float()
		if node.get_child_by_name("AccelerationDelay"):
			proj.acceleration_delay = node.get_child_by_name("AccelerationDelay").content.to_int()
		if node.get_child_by_name("Amplitude"):
			proj.amplitude = node.get_child_by_name("Amplitude").content.to_float()
		if node.get_child_by_name("Frequency"):
			proj.frequency = node.get_child_by_name("Frequency").content.to_float()
		if node.get_child_by_name("CircleTurnDelay"):
			proj.circle_turn_delay = node.get_child_by_name("CircleTurnDelay").content.to_int()
		if node.get_child_by_name("CircleTurnAngle"):
			proj.circle_turn_angle = node.get_child_by_name("CircleTurnAngle").content.to_float()
		if node.get_child_by_name("TurnRate"):
			proj.turn_rate = node.get_child_by_name("TurnRate").content.to_float()
		if node.get_child_by_name("TurnRateDelay"):
			proj.turn_rate_delay = node.get_child_by_name("TurnRateDelay").content.to_int()
		if node.get_child_by_name("TurnStopTime"):
			proj.turn_stop_time = node.get_child_by_name("TurnStopTime").content.to_int()
		if node.get_child_by_name("TurnAcceleration"):
			proj.turn_acceleration = node.get_child_by_name("TurnAcceleration").content.to_float()
		if node.get_child_by_name("TurnAccelerationDelay"):
			proj.turn_acceleration_delay = node.get_child_by_name("TurnAccelerationDelay").content.to_int()
		if node.get_child_by_name("TurnClamp"):
			proj.turn_clamp = node.get_child_by_name("TurnClamp").content.to_float()
		if node.get_child_by_name("MultiHit"):
			proj.multi_hit = true
		if node.get_child_by_name("PassesCover"):
			proj.passes_cover = true
		if node.get_child_by_name("ArmorPiercing"):
			proj.armor_piercing = true
		if node.get_child_by_name("ProtectFromSink"):
			proj.protect_from_sink = true
		if node.get_child_by_name("FaceDir"):
			proj.face_dir = true
		if node.get_child_by_name("Wavy"):
			proj.wavy = true
		if node.get_child_by_name("Boomerang"):
			proj.boomerang = true
		if node.get_child_by_name("Parametric"):
			proj.parametric = true
		if node.get_children_by_name("ParticleTrail"):
			var trail := node.get_child_by_name("ParticleTrail")
			proj.particle_trail_enabled = true
			proj.particle_trail_intensity = trail.attributes.get("intensity", "1.0").to_float()
			proj.particle_trail_lifetime_ms = trail.attributes.get("lifetimeMS", "500").to_int()

		return proj

class BulletCreate extends Resource:
	signal updated()
	
	# Tool specific
	var enabled: bool = true
	# Generic Activate
	var cooldown: float = 0.0
	var proc: float = 1.0
	var target_mouse: bool = true
	var target_mouse_range: float = 3.0
	# BulletCreate specific
	var type: int = 0
	var min_distance: float = 0
	var max_distance: float = 4.4
	var offset_angle: float = 90.0
	var num_shots: int = 3
	var gap_angle: float = 45.0
	var gap_tiles: float = 0.5
	var arc_gap: float = 0.0
	var scailing_stat: String = ""
	var stat_mod_scaling_min: int = 0
	var stat_mod_damage: float = 0.0
	var stat_mod_num_shots: float = 0.0
	var origin: String = "target"
	
	func _set(_property: StringName, _value: Variant) -> bool:
		updated.emit()
		return false
	
	func copy() -> BulletCreate:
		var out = BulletCreate.new()
		
		for prop in out.get_property_list():
			out.set(prop["name"], get(prop["name"]))
		
		return out
	
	func float_to_string(a: float) -> String:
		return XMLObjects.float_to_string(a)
		
	func to_xml(_index: int) -> String:
		push_error("TOOD: Implement BulletCreate.to_xml()")
		return ""
	
	static func parse(node: XMLNode, base: XMLObjects.BulletCreate = XMLObjects.BulletCreate.new()) -> XMLObjects.BulletCreate:
		var bc = base.copy()
		push_error("TOOD: Implement BulletCreate.parse()")
		return bc

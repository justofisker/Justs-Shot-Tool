extends Node2D

const Projectile = preload("res://bullet_area/projectile.gd")

func add_projectile(proj: Projectile) -> void:
	%ProjectileContainer.add_child(proj)
	proj.scale = Vector2.ONE * proj.proj.size / 100.0
	
	if !ProjectileManager.finished_loading:
		return
	
	var object : XMLProjectileVisual = ProjectileManager.objects.get(proj.proj.object_id)
	if object:
		proj.rotation_rate = object.rotation
		var sprite := Sprite2D.new()
		if object.random_textures.size() != 0:
			sprite.texture = ProjectileManager.get_texture(object.random_textures.pick_random())
		elif object.texture:
			sprite.texture = ProjectileManager.get_texture(object.texture)
		sprite.scale = Vector2.ONE * 0.5
		sprite.rotation = PI / 4 * object.angle_correction
		proj.add_child(sprite)
		if object.animation:
			var player := AnimationPlayer.new()
			var animation := Animation.new()
			var track_index := animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(track_index, "%s:texture" % sprite.get_path())
			animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_NEAREST)
			var duration := 0.0
			for idx in object.animation.frames.size():
				duration += object.animation.frame_durations[idx]
			animation.length = duration
			animation.loop_mode = Animation.LOOP_NONE if is_equal_approx(proj.proj.lifetime_ms / 1000.0, duration) else Animation.LOOP_LINEAR
			var time := 0.0
			for idx in object.animation.frames.size():
				animation.track_insert_key(track_index, time, ProjectileManager.get_texture(object.animation.frames[idx]))
				time += object.animation.frame_durations[idx]
			var library := AnimationLibrary.new()
			library.add_animation("default", animation)
			player.add_animation_library("", library)
			player.autoplay = "default"
			sprite.add_child(player)

func _ready() -> void:
	Bridge.set_deferred("selected_object", $Object)

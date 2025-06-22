class_name BulletManager
extends Node2D

var bullets = []
var updated_bullet_pic = {}
var in_screen_bullet = 0
var clear = false

# Pre-allocated color array to avoid repeated allocations
var _white_colors = PackedColorArray()

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Pre-allocate color array for common vertex counts
	_white_colors.resize(16) # Most bullets have 4 vertices, but allow for more
	_white_colors.fill(Color.WHITE)

func _draw():
	for polygon in updated_bullet_pic.keys():
		var vertices = polygon[0]
		var uvs = polygon[1] 
		var texture = updated_bullet_pic[polygon]
		
		# Basic validation without expensive fallbacks
		if texture != null and vertices.size() >= 3:
			# Handle atlas textures efficiently
			var render_texture = texture.atlas if texture.atlas != null else texture
			
			# Reuse pre-allocated color array or create minimal one
			var colors: PackedColorArray
			if vertices.size() <= _white_colors.size():
				# Slice the pre-allocated array
				colors = _white_colors.slice(0, vertices.size())
			else:
				# Only allocate if necessary for large polygons
				colors = PackedColorArray()
				colors.resize(vertices.size())
				colors.fill(Color.WHITE)
			
			draw_polygon(vertices, colors, uvs, render_texture)

func get_bullet_polygon(bullet, texture: AtlasTexture):
	# Quick validation without expensive fallbacks
	if not texture in RS.bullet_polygons:
		# Use original simple fallback for missing textures
		var polygon = RS.bullet_polygons.values()[0] if RS.bullet_polygons.size() > 0 else null
		if polygon == null:
			return [PackedVector2Array(), PackedVector2Array()]
		return [polygon[0], polygon[1]]
	
	var polygon = RS.bullet_polygons[texture]
	var pos_offset = texture.get_size()/2
	var polygon_array = []
	
	# Scaling operations
	var scaled_polygon = [polygon[0][0],
	polygon[0][1]*bullet.scale.x,
	polygon[0][2]*bullet.scale,
	polygon[0][3]*bullet.scale.y]
	pos_offset *= bullet.scale
	
	# Rotation and translation
	for polygon_pos in scaled_polygon:
		polygon_pos -= pos_offset
		if !bullet.no_pic_rotation:
			polygon_pos = polygon_pos.rotated(deg_to_rad(bullet.show_rotation))
		polygon_pos += bullet.position
		polygon_array.append(polygon_pos)
		polygon_array = PackedVector2Array(polygon_array)
	
	return [polygon_array, polygon[1]]

func _process(delta):
	if clear:
		# Batch clear all bullets
		var bullets_to_clear = bullets.duplicate()
		for bullet in bullets_to_clear:
			remove_bullet(bullet)
		clear = false
		return
	move_bullets(delta)

func create_bullet_bul(bullet):
	bullet._initlize()
	bullets.append(bullet)

func get_new_bullet(attr := {}):
	return Bullet.new(attr)

func remove_bullet(bullet):
	STGSYS.enemy_bullets.erase(bullet)
	bullets.erase(bullet)
	bullet.free()

func clear_all_bullets():
	clear = true

func add_bullet_to_update(bullet):
	# Minimal validation with caching
	var bullet_pics_for_type = RS.bullet_pics.get(bullet.bullet_type)
	if not bullet_pics_for_type or bullet_pics_for_type.size() == 0:
		return
	
	# Clamp color index efficiently
	var color_index = bullet.color
	if color_index >= bullet_pics_for_type.size():
		color_index = 0
	
	var pic = bullet_pics_for_type[color_index]
	if pic == null:
		return
		
	var polygon = get_bullet_polygon(bullet, pic)
	updated_bullet_pic[polygon] = pic

func move_bullets(delta):
	updated_bullet_pic = {}
	in_screen_bullet = 0
	var bullets_to_remove = []
	
	for bullet in bullets:
		bullet.move(delta)
		add_bullet_to_update(bullet)
		bullet.collision_detect()
			
		# Screen bounds checking
		if bullet.position.x > STGSYS.view_portsize.x + 40*bullet.scale.x or \
		bullet.position.x < -40*bullet.scale.x or bullet.position.y < -40*bullet.scale.y or \
		bullet.position.y > STGSYS.view_portsize.y + 40*bullet.scale.y:
			if bullet.out_screen_remove:
				bullet.wait_for_remove = true
			else:
				in_screen_bullet += 1
			
		# Life countdown for persistent bullets
		if !bullet.out_screen_remove:
			if bullet.life > 0:
				bullet.life -= 1
			else:
				bullet.wait_for_remove = true
		
		# Collect bullets to remove in batch
		if bullet.wait_for_remove:
			bullets_to_remove.append(bullet)
	
	# Remove marked bullets in batch to avoid modifying array during iteration
	for bullet in bullets_to_remove:
		remove_bullet(bullet)
	queue_redraw()

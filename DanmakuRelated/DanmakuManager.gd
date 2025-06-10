class_name BulletManager
extends Node2D

var bullets = []
var updated_bullet_pic = {}
var in_screen_bullet = 0
var clear = false

func _ready():
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _draw():
	for polygon in updated_bullet_pic.keys():
		var vertices = polygon[0]
		var uvs = polygon[1] 
		var texture = updated_bullet_pic[polygon]
		
		if texture != null and vertices.size() >= 3:
			# For AtlasTexture, we need to use the atlas texture, not the AtlasTexture itself
			var atlas_texture = texture.atlas if texture.atlas != null else texture
			
			var colors = PackedColorArray()
			colors.resize(vertices.size())
			#colors.fill(Color.WHITE)
			
			draw_polygon(vertices, colors, uvs, atlas_texture)
		else:
			# Fallback: draw a simple colored polygon for debugging
			if vertices.size() >= 3:
				draw_colored_polygon(vertices, Color.RED)
		
		# Additional debug: draw outline for all player bullets
		#if vertices.size() >= 3:
			#var center = Vector2.ZERO
			#for vertex in vertices:
				#center += vertex
			#center /= vertices.size()
			#if center.y > STGSYS.view_portsize.y * 0.5:
				#var outline_color = Color.CYAN
				#for i in range(vertices.size()):
					#var next_i = (i + 1) % vertices.size()
					#draw_line(vertices[i], vertices[next_i], outline_color, 2.0)

func get_bullet_polygon(bullet,texture:AtlasTexture):
	if not texture in RS.bullet_polygons:
		print("[ERROR] Texture not found in bullet_polygons for bullet type:", bullet.bullet_type)
		# Create a fallback polygon
		var size = texture.get_size()
		var fallback_polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, size.y), Vector2(0, size.y)
		])
		var fallback_uv = PackedVector2Array([
			Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)
		])
		return [fallback_polygon, fallback_uv]
	
	var polygon = RS.bullet_polygons[texture]
	#将定义好的多边形加上坐标得出解
	var pos_offset = texture.get_size()/2
	var polygon_array = []
	
	#先给多边形进行缩放操作
	var scaled_polygon = [polygon[0][0],\
	polygon[0][1]*bullet.scale.x,\
	polygon[0][2]*bullet.scale,\
	polygon[0][3]*bullet.scale.y]
	pos_offset*=bullet.scale
	
	#然后给多边形进行旋转和平移操作
	for polygon_pos in scaled_polygon:
		polygon_pos -= pos_offset
		if !bullet.no_pic_rotation:
			polygon_pos = polygon_pos.rotated(deg_to_rad(bullet.show_rotation))
		polygon_pos += bullet.position
		polygon_array.append(polygon_pos)
		polygon_array = PackedVector2Array(polygon_array)
	
	# Use the corrected UV coordinates from RS.bullet_polygons[texture][1]
	return [polygon_array, polygon[1]]

func _process(delta):
	if clear:
		for bullet in bullets:
			remove_bullet(bullet)
	move_bullets(delta)

#将一个新的子弹添加进管理器
func create_bullet_bul(bullet):
	#bullet._initialize()
	bullet._initlize()
	bullets.append(bullet)

func get_new_bullet(attr := {}):
	#获取一个没有任何配置的新的弹幕
	return Bullet.new(attr)

func remove_bullet(bullet):
	STGSYS.enemy_bullets.erase(bullet)
	bullets.erase(bullet)
	bullet.free()

#消除所有弹幕
func clear_all_bullets():
	clear = true

func add_bullet_to_update(bullet):
	# Check if the bullet type exists in our collection
	if not bullet.bullet_type in RS.bullet_pics:
		print("[ERROR] Bullet type", bullet.bullet_type, "not found in bullet_pics!")
		return
	
	# Check if there are any frames for this bullet type
	if RS.bullet_pics[bullet.bullet_type].size() == 0:
		print("[ERROR] No frames found for bullet type", bullet.bullet_type)
		return
	
	# Check if the color index is valid for this bullet type
	if bullet.color >= RS.bullet_pics[bullet.bullet_type].size():
		print("[WARNING] Color index", bullet.color, "is out of range for bullet type", 
			bullet.bullet_type, ". Using color index 0 instead.")
		bullet.color = 0 # Default to color index 0 if out of range
	
	var pic = RS.bullet_pics[bullet.bullet_type][bullet.color]
	if pic == null:
		print("[ERROR] Picture is null for bullet type:", bullet.bullet_type, ", color:", bullet.color)
		return
		
	var polygon = get_bullet_polygon(bullet, pic)
	updated_bullet_pic[polygon] = pic
	
	# Debug for player bullets
	#if bullet.b_owner == "self":
		#print("[PLAYER BULLET DEBUG] Added to render queue")
		#print("  - Type:", bullet.bullet_type, ", Color:", bullet.color) 
		#print("  - Position:", bullet.position, ", Scale:", bullet.scale)
		#print("  - Polygon vertices:", polygon[0].size(), ", Texture valid:", pic != null)
		#print("  - Polygon points:", polygon[0])
		#print("  - UV coordinates:", polygon[1])
		#if pic != null:
			#print("  - Texture size:", pic.get_size(), ", Atlas size:", pic.atlas.get_size() if pic.atlas else "No atlas")
	
	# Debug for bomb  
	#if bullet.b_owner == "self_bomb":
		#print("[BOMB BULLET DEBUG] Added to render queue")
		#print("  - Type:", bullet.bullet_type, ", Color:", bullet.color) 
		#print("  - Position:", bullet.position, ", Scale:", bullet.scale)
		#print("  - Polygon vertices:", polygon[0].size(), ", Texture valid:", pic != null)
		#print("  - Damage:", bullet.damage, ", Unbreakable:", bullet.unbreakable)

func move_bullets(delta):
	updated_bullet_pic = {}
	in_screen_bullet = 0
	for bullet in bullets:
		#开始处理子弹的移动逻辑
		bullet.move(delta)
			
		add_bullet_to_update(bullet)
		#运行判定逻辑
		bullet.collision_detect()
			
		#判定子弹是否超出屏幕范围
		if bullet.position.x > STGSYS.view_portsize.x + 40*bullet.scale.x or \
		bullet.position.x < -40*bullet.scale.x or bullet.position.y < -40*bullet.scale.y or \
		bullet.position.y > STGSYS.view_portsize.y + 40*bullet.scale.y:
			#超出屏幕后清理子弹
			if bullet.out_screen_remove:
				bullet.wait_for_remove = true
			else:
				in_screen_bullet+=1
			
		#子弹的出屏即消关掉时计算多久删除子弹
		if !bullet.out_screen_remove:
			if bullet.life > 0:
				bullet.life -=1
			else:
				bullet.wait_for_remove = true
	
	for bullet in bullets:
		if bullet.wait_for_remove:
			remove_bullet(bullet)
	queue_redraw()

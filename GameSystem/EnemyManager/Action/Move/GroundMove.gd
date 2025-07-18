class_name GroundMove
extends Move

func try_move(delta: float) -> void:
	var new_velocity = target.velocity

	# 施加重力
	if not target.is_on_floor():
		new_velocity += target.get_gravity() * delta

	# 处理左右移动
	new_velocity.x = try_move_x(new_velocity.x, delta)

	# 处理跳跃
	new_velocity.y = try_move_y(new_velocity.y, delta)

	target.velocity = new_velocity

func try_move_y(value, delta) -> float:
	if _can_jump():
		value = -MAX_SPEED.y
	return value



func _need_jump()-> bool:
	var dict = Utility.raycast(
		target.global_position,
		target.global_position + Vector2(_get_move_vec().x * 15.0, 0.0)
	)
	if dict:
		var collider:Node2D = dict["collider"]
		if collider.is_in_group("Block"):
			return true
		#if collider.is_in_group("Enemy"):
			#return true

	return false

func _can_jump()-> bool:
	var area = %FloorDetectArea
	#if not area:
		#return _need_jump()
	if area:
		for i:Node2D in area.get_overlapping_bodies():
			if i == self:
				continue
			if i.is_in_group("Enemy") \
			or i.is_in_group("Block"):
				return _need_jump()
	return false

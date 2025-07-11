class_name GroundMove
extends Move

func try_move(delta: float) -> void:
	var new_velocity = target.velocity

	# 施加重力
	if not target.is_on_floor():
		new_velocity.y += GRAVITY * delta

	# 处理左右移动
	new_velocity.x = try_move_x(new_velocity.x, delta)

	# 处理跳跃
	new_velocity.y = try_move_y(new_velocity.y, delta)

	target.velocity = new_velocity

func try_move_y(value, delta) -> float:
	if _need_jump() and _can_jump():
		value = -JUMP_SPEED
	return value



func _need_jump()-> bool:
	var dict = Utility.raycast(
		target.global_position,
		target.global_position + Vector2(_get_move_vec().x * 15.0, 0.0)
	)
	if not dict:
		return false

	if (dict["collider"] as Node2D).is_in_group("Block"):
		return true
	#if (dict["collider"] as Node2D).is_in_group("Enemy"):
		#return true

	return false

func _can_jump()-> bool:
	for i: Node2D in %FloorDetectArea.get_overlapping_bodies():
		if i != self and \
		 (i.is_in_group("Enemy") or \
		 i.is_in_group("Block")):
			return true
	return false
#

func get_move_pos():
	var move_pos = super()
	if social_distance.x != 0:
		var distance = move_pos.x - target.position.x
		if distance > 0:
			move_pos.x -= social_distance.x
		elif distance < 0:
			move_pos.x += social_distance.x
	return move_pos

class_name GroundMove
extends Move

var can_jump:bool = false



func _physics_process(delta: float) -> void:
	update_can_jump()
	super(delta)



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

func try_move_x(value:float, delta:float) -> float:
	# 处理左右移动
	var vec = _get_move_vec()
	if vec.x != 0: 
		return lerp(value, MAX_SPEED.x * vec.x, INCREASE * delta)
	else: # 停止移动
		return lerp(value, 0.0, DECREASE * delta)

func try_move_y(value:float, delta:float) -> float:
	if can_jump:
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
		if collider.is_in_group("Enemy"):
			return true

	return false

func update_can_jump():
	can_jump = false

	var area = %FloorDetectArea
	if area:
		for i:Node2D in area.get_overlapping_bodies():
			if i == target:
				continue
			if i.is_in_group("Enemy") \
			or i.is_in_group("Block"):
				can_jump = _need_jump()
				return

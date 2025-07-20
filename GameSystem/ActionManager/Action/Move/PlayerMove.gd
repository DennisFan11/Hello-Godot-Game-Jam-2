class_name PlayerMove
extends Move

enum {IDLE, ON_WALL}
var state: int = IDLE



func _ready() -> void:
	PlayerUpgradeSystem.stats_updated.connect(_on_stats_updated)

func _on_stats_updated(stats):
	MAX_SPEED = Vector2(stats.move_speed, stats.jump_power)



func try_move(delta: float) -> void:
	var new_velocity = target.velocity
	var vec = _get_move_vec()
	var climb = 1 if _climb_R() else (-1 if _climb_L() else 0)

	match state:
		IDLE:
			# 施加重力
			new_velocity += target.get_gravity() * delta

			# 处理左右移动 - 使用動態速度
			if vec.x != 0:
				new_velocity.x = lerp(new_velocity.x, MAX_SPEED.x * vec.x, INCREASE * delta)
			else: # 停止移动
				new_velocity.x = lerp(new_velocity.x, 0.0, DECREASE * delta)

			# 处理跳跃 - 使用動態跳躍力
			if target.is_on_floor():
				if Input.is_action_just_pressed("space"): 
					new_velocity.y = - MAX_SPEED.y
			else:
				if new_velocity.y > 0.0 and \
				climb and \
				Input.is_action_pressed("shift"):
					state = ON_WALL
		ON_WALL:
			# 牆壁吸附力
			new_velocity.x = 50.0 * climb

			# 上下移動
			if vec.y != 0:
				new_velocity.y = lerp(new_velocity.y, MAX_SPEED.x * vec.y, INCREASE * delta)
			else:
				new_velocity.y = lerp(new_velocity.y, 0.0, DECREASE * delta)

			# 離開牆壁
			if not climb or \
				!Input.is_action_pressed("shift"):
				state = IDLE

			# 蹬牆跳
			if Input.is_action_just_pressed("space"):
				new_velocity.x = MAX_SPEED.x * 1.25 * (1 if new_velocity.x < 0.0 else -1)
				new_velocity.y = -MAX_SPEED.y
				state = IDLE

	# 轉向
	change_direction(new_velocity)
	
	target.velocity = new_velocity

## 若正在移動, 更改面朝方向
func change_direction(velocity):
	if velocity.x == 0.0:
		return

	var new_direction = velocity.x > 0.0
	if state == ON_WALL:
		new_direction = not new_direction

	if new_direction == direction:
		return

	%Body.scale.x = 1 if new_direction else -1
	direction = new_direction

# 檢測角色與Block的碰撞方向
# -1:左 0:無 1:右
#func _climb() -> int:
	#var slide_collision = get_last_slide_collision()
#
	#if slide_collision \
	#and slide_collision.get_collider().is_in_group("Block"):
		#if is_zero_approx(slide_collision.get_angle(Vector2.LEFT)):
			#return 1
		#elif is_zero_approx(slide_collision.get_angle(Vector2.RIGHT)):
			#return -1
	#return 0

func _climb_R() -> bool:
	for i in %RightArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

func _climb_L() -> bool:
	for i in %LeftArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

func _get_move_vec() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

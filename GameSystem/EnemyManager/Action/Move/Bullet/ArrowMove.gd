class_name ArrowMove
extends BulletMove

var jump:bool = true

func _physics_process(delta: float) -> void:
	if not enable: return

	try_move(delta)
	
	# 碰撞後停止移動, 模擬箭插在牆上
	if target.move_and_slide():
		target.velocity = Vector2.ZERO
		enable = false

func try_move(delta:float):
	var new_velocity = target.velocity

	if jump:
		var pos = _get_player_distance()
		# 初始角度
		# 向上45度(90 +- 45)
		var rad = deg_to_rad(45 if pos.x > 0.0 else 135)

		# 初始速度
		var v0 = sqrt(
			(target.get_gravity().y * pos.x ** 2) /
			(2 * cos(rad) ** 2 * (pos.x * tan(rad) + pos.y))
		)
		
		new_velocity = Vector2(v0 * cos(rad), -v0 * sin(rad))

		# 限制最高速度
		new_velocity = Vector2(
			clamp(new_velocity.x, -MAX_SPEED.x, MAX_SPEED.x),
			max(new_velocity.y, -MAX_SPEED.y)
		)

		# 增加隨機
		new_velocity += get_variance_vec()

		jump = false
	else:
		new_velocity += target.get_gravity() * delta

	target.velocity = new_velocity

	if new_velocity != Vector2.ZERO:
		target.rotation = new_velocity.angle()

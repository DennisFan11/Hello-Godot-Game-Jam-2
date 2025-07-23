class_name FlyMove
extends Move

## 最大轉動角度
## 當數值為0時不限制轉動
@export_range(0, 180) var max_rotation_angle:float = 0.0:
	set(value):
		max_rotation_angle = value
		max_directional_angle_rad = deg_to_rad(value)

## 移動時調整角色轉向
@export var move_rotation:bool = false

var max_directional_angle_rad:float
var current_move_angle:float = INF

func try_move(delta:float):
	var new_velocity = target.velocity
	# 防止到達目標位置時抖動
	# 如果有限制轉動的話抖動會變成自行迴旋, 也許可以加上這個條件?
	if target.position.distance_squared_to(get_move_pos()) <= MAX_SPEED.length_squared() * delta:
		new_velocity = Vector2.ZERO
	else:
		var vec = _get_move_vec()
		var new_angle = vec.angle()

		if max_rotation_angle > 0.0 and current_move_angle != INF:
			current_move_angle = get_move_angle(
				new_angle,
				current_move_angle,
				max_directional_angle_rad * delta
			)

			vec = Vector2(
				cos(current_move_angle),
				sin(current_move_angle)
			).normalized()
		else:
			current_move_angle = new_angle

		new_velocity = MAX_SPEED * vec

	if move_rotation:
		target.rotation = current_move_angle
	target.velocity = new_velocity



# 獲取目前可移動的角度
func get_move_angle(target_angle, current_angle, max_diff):
	var diff_angle = target_angle - current_angle

	if not is_zero_approx(diff_angle):
		while diff_angle > PI:
			diff_angle -= PI * 2
		while diff_angle < -PI:
			diff_angle += PI * 2

		if diff_angle >= max_diff:
			target_angle = current_angle + max_diff
		elif diff_angle <= -max_diff:
			target_angle = current_angle - max_diff
	return target_angle

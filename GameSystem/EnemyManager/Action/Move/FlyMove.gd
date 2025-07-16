class_name FlyMove
extends Move

@export var floating_height:float = 2.5

var floating_timer = 0

func try_move(delta:float):
	var new_velocity = target.velocity

	new_velocity.x = try_move_x(new_velocity.x, delta)
	new_velocity.y = try_move_y(new_velocity.y, delta)
	
	target.velocity = new_velocity

#func try_move_x(value:float, delta:float):
	#var distance:Vector2 = _get_player_distance().x
	#var target_x:float = 0.0
	#
	#var target_pos:float = 0.0
	#if distance < 0 and distance - social_distance.x != 0:
		#vec = (distance - social_distance.x)
	#elif distance > 0 and distance + social_distance.x != 0:
	#
	#if vec.x != 0: 
		#return lerp(value, MAX_SPEED * vec.x, INCREASE * delta)
	#else: # 停止移动
		#return lerp(value, 0.0, DECREASE * delta)

func try_move_y(value:float, delta:float):
	var current_y = target.position.y
	var target_y = get_move_pos().y + sin(floating_timer) * floating_height

	floating_timer += delta

	if current_y == target_y:
		value = 0
	else:
		value = MAX_SPEED.y * clamp(target_y - current_y, -1, 1)

	return value



func get_move_pos():
	var move_pos = super()
	if social_distance != Vector2.ZERO:
		var distance:Vector2 = move_pos - target.position
		if distance != Vector2.ZERO:
			if distance.x > 0:
				move_pos.x -= social_distance.x
			elif distance.x < 0:
				move_pos.x += social_distance.x

			move_pos.y -= social_distance.y
	return move_pos

class_name FlyMove
extends Move

@export var floating_height:float = 2.5

var floating_timer = 0

func try_move(delta:float):
	var new_velocity = target.velocity

	new_velocity.x = try_move_x(new_velocity.x, delta)
	new_velocity.y = try_move_y(new_velocity.y, delta)
	
	target.velocity = new_velocity

func try_move_y(value:float, delta:float):
	var current_y = target.position.y
	var target_y = get_move_pos().y + sin(floating_timer) * floating_height

	floating_timer += delta

	if current_y == target_y:
		value = 0
	else:
		value = MAX_SPEED.y * clamp(target_y - current_y, -1, 1)

	return value

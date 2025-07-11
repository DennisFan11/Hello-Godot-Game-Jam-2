class_name JumpMove
extends GroundMove

var move_pos:Vector2 = Vector2.ZERO

func try_move_x(value:float, delta:float):
	if target.velocity.y == 0.0:
		value = 0
	else:
		value = super(value, delta)
	return value

func _need_jump() -> bool:
	if target.is_on_floor():
		if _cooldown_timer.is_ready():
			_cooldown_timer.trigger(cooldown)
			return true
	return false

func get_move_pos():
	if _can_jump():
		move_pos = super()
	return move_pos

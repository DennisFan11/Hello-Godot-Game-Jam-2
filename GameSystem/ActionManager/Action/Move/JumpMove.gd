class_name JumpMove
extends GroundMove

# 固定跳躍時的目標位置, 方便玩家躲避
var move_pos:Vector2 = Vector2.ZERO



func try_move_x(value:float, delta:float):
	if target.velocity.y == 0.0:
		value = 0
	else:
		value = super(value, delta)
	return value

func try_move_y(value:float, _delta:float):
	if can_jump:
		value = -MAX_SPEED.y
	return value

func _need_jump() -> bool:
	if _cooldown_timer.is_ready():
		_cooldown_timer.trigger(cooldown)
		return true
	return false

func get_move_pos():
	if can_jump or move_pos == Vector2.ZERO:
		move_pos = super()
	return move_pos

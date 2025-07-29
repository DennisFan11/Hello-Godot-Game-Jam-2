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

func jump():
	move_pos = super.get_move_pos()
	return super()

func _need_jump() -> bool:
	if _cooldown_timer.is_ready():
		_cooldown_timer.trigger(cooldown)
		return true
	return false

func get_move_pos():
	return move_pos

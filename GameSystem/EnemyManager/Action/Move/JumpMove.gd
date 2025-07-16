class_name JumpMove
extends GroundMove

var jump:bool = true
var move_pos:Vector2 = Vector2.ZERO

func try_move(delta:float):
	_can_jump()
	super(delta)
	jump = false

func try_move_x(value:float, delta:float):
	if target.velocity.y == 0.0:
		value = 0
	else:
		value = super(value, delta)
	return value

func try_move_y(value:float, delta:float):
	if jump:
		value = -MAX_SPEED.y
	return value

func _need_jump() -> bool:
	if _cooldown_timer.is_ready():
		_cooldown_timer.trigger(cooldown)
		jump = true
	return jump

func get_move_pos():
	if jump or move_pos == Vector2.ZERO:
		move_pos = super()
	return move_pos

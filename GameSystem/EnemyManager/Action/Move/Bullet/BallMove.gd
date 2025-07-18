class_name BallMove
extends BulletMove

var vec:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	super(delta)

	# 反彈
	var slide_collision = target.get_last_slide_collision()
	if slide_collision:
		var normal = -abs(slide_collision.get_normal())
		if normal.x != 0.0:
			vec.x *= normal.x
		if normal.y != 0.0:
			vec.y *= normal.y

func try_move(delta: float) -> void:
	target.velocity = MAX_SPEED * _get_move_vec()

func _get_move_vec()-> Vector2:
	if vec == Vector2.ZERO:
		vec = super()
	return vec

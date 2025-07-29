class_name BallMove
extends BulletMove

@export var bounce:bool = true

var vec:Vector2 = Vector2.INF

func _physics_process(delta: float) -> void:
	super(delta)

	# 撞牆後反彈
	if bounce:
		var slide_collision = control_target.get_last_slide_collision()
		if slide_collision:
			var normal = -abs(slide_collision.get_normal())
			if normal.x != 0.0:
				vec.x *= normal.x
				
			if normal.y != 0.0:
				vec.y *= normal.y

func try_move(_delta: float) -> void:
	if vec == Vector2.INF:
		vec = MAX_SPEED * _get_move_vec()

		# 增加隨機
		vec += get_variance_vec()

	target.velocity = vec

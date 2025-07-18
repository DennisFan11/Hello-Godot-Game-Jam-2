class_name BulletMove
extends Move

func get_rng_vec(min_range:Vector2 = Vector2.INF, max_range:Vector2 = Vector2.INF):
	if min_range == Vector2.INF:
		min_range = -MAX_SPEED / 10
	if max_range == Vector2.INF:
		max_range = MAX_SPEED / 10
	return Vector2(
		randf_range(min_range.x, max_range.x),
		randf_range(min_range.y, max_range.y)
	)

class_name TouchAttack
extends Attack

func try_attack(delta: float) -> void:
	var last_slide_collision = target.get_last_slide_collision()
	if last_slide_collision:
		var collider = last_slide_collision.get_collider()
		if collider is Player:
			collider.take_damage(damage)
			_cooldown_timer.trigger(0.5)

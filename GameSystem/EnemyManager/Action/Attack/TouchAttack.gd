class_name TouchAttack
extends Attack

# 觸碰玩家時攻擊
func try_attack(delta: float) -> void:
	var slide_collision = target.get_last_slide_collision()
	if slide_collision:
		var collider = slide_collision.get_collider()
		if collider is Player:
			collider.take_damage(damage)

			if cooldown > 0.0:
				_cooldown_timer.trigger(cooldown)
			elif cooldown < 0.0: # 當<0時將在擊中後刪除, 主要用於投射物(箭)
				target.queue_free()

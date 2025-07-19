class_name TouchAttack
extends Attack

# 觸碰玩家時攻擊
func try_attack(delta: float) -> void:
	if target is CharacterBody2D:
		try_attack_char(delta)
	elif target is Area2D:
		try_attack_area(delta)

func try_attack_char(delta):
	var slide_collision = target.get_last_slide_collision()
	if slide_collision:
		var collider = slide_collision.get_collider()
		if collider is Player:
			attack(collider)

func try_attack_area(delta):
	var node_list = target.get_overlapping_bodies()
	for node in node_list:
		if node is Player:
			attack(node)
			return

class_name TouchAttack
extends Attack

# 觸碰玩家時攻擊
func try_attack(delta: float) -> void:
	if control_target is CharacterBody2D:
		try_attack_char(delta, control_target)
	elif control_target is Area2D:
		try_attack_area(delta, control_target)
	elif control_target is Weapon:
		try_attack_weapon(delta)

func try_attack_char(_delta:float, body:CharacterBody2D):
	var collision = body.get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group(attack_type):
			attack(collider)

func try_attack_area(_delta:float, area:Area2D):
	var node_list = area.get_overlapping_bodies()
	for node:Node in node_list:
		if node.is_in_group(attack_type):
			attack(node)

func try_attack_weapon(delta:float):
	var area = %PhysicalComponent.get_attack_area()
	if area: try_attack_area(delta, area)

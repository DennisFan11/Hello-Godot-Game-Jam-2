class_name TouchAttack
extends Attack

# 觸碰玩家時攻擊
func try_attack(delta: float) -> void:
	if target is CharacterBody2D:
		try_attack_char(delta, target.get_last_slide_collision())
	elif target is Area2D:
		try_attack_area(delta, target)
	elif target is Weapon:
		try_attack_weapon(delta)

func try_attack_char(_delta, collision):
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group(attack_type):
			attack(collider)

func try_attack_area(_delta, area):
	var node_list = area.get_overlapping_bodies()
	print(len((node_list as Array[Node]).filter(func(n):return n is Bullet)))
	for node:Node in node_list:
		if node.is_in_group(attack_type):
			attack(node)
			return

func try_attack_weapon(delta):
	var area = %PhysicalComponent.get_node("AttackArea")
	if area: try_attack_area(delta, area)

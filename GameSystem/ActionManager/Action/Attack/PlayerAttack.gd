class_name PlayerAttack
extends Attack

func try_attack(_delta):
	if not Input.is_action_just_pressed("attack"):
		return

	var cooldown_reduction = PlayerUpgradeSystem.get_stats("skill_cooldown_reduction")

	var actual_cooldown = max(0.1, 1.0 - cooldown_reduction)
	_cooldown_timer.trigger(actual_cooldown)

	# 這裡可以添加攻擊邏輯 TODO
	%WeaponSlot.start_attack(0.2)

	#print("攻擊！傷害：",  attack_damage)

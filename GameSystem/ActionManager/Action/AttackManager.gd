class_name AttackManager
extends ActionManager

func update_attack_type():
	for children in get_children():
		children.update_attack_type()

class_name AttackManager
extends ActionManager

func update_attack_type():
	for child in get_children() \
	.filter(func(c): return c is Attack):
		child.update_attack_type()

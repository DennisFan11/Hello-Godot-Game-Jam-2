class_name ArrowAttack
extends Attack

var bullet = preload("uid://632eff4dpxmu")

func try_attack(delta):
	var node:Bullet = bullet.instantiate()
	node.position = target.position
	add_child(node)
	_cooldown_timer.trigger(cooldown)

class_name BulletAttack
extends Attack

@export var bullet:PackedScene = preload("uid://632eff4dpxmu")

func try_attack(delta):
	var node:Bullet = bullet.instantiate()
	
	node.summoner = target
	node.position = target.position

	add_child(node)
	_cooldown_timer.trigger(cooldown)

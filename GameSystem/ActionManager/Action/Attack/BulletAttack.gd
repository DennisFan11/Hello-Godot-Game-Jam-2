class_name BulletAttack
extends Attack

@export var bullet:PackedScene = preload("uid://632eff4dpxmu")
@export var spawn_pos:Node2D

var _game_manager: GameManager
func try_attack(delta):
	var node:Bullet = bullet.instantiate()
	
	node.summoner = target.summoner if target is Derivative else target
	node.global_position = spawn_pos.global_position if spawn_pos else target.global_position

	# 使bullet生成到GameManager的BulletManager, 避免位置隨角色移動
	_game_manager.spawn_bullet(node)

	_cooldown_timer.trigger(cooldown)

class_name Enemy
extends CharacterBody2D

# 敵人死亡信號
signal died(enemy: Enemy)

@export var _hp: float = 30


func damage(dmg: float):
	_hp -= dmg
	if _hp < 0.0: _dead()

func push(vec: Vector2):
	pass

func _dead():
	died.emit(self) # 發射死亡信號，傳遞自己的引用
	queue_free()

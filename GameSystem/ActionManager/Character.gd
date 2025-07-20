class_name Character
extends CharacterBody2D

signal died(character:Character)

@export var max_hp: int = 30
@export var attack_damage: int = 0

var _hp: int = 30



func health_change(value: int):
	_hp = clampi(_hp + value, 0, max_hp)

# 回復生命值
func heal(value: int):
	health_change(value)

# 受到傷害
func take_damage(value: int):
	health_change(-value)

	if _hp == 0:
		dead()

func dead():
	died.emit(self)

class_name Weapon
extends Node2D

## 武器傷害
@export var DMG: float = 15.0
## 
#@export var SPEED: float = 0.2
## 武器重量
@export var WEIGHT: float = 3.0
## 武器使用動畫
@export var ANIM: String = "SwordType"

func get_damage():
	# 武器傷害 + 升級傷害增加
	return DMG + PlayerUpgradeSystem.player_stats.attack_damage

# used by player
func frame_attack(delta: float):
	pass

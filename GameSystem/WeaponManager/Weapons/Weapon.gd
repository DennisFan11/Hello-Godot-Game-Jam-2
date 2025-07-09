class_name Weapon
extends Node2D

var id: String = "sword"

## 武器傷害
@export var DMG: float = 15.0
## 
#@export var SPEED: float = 0.2
## 武器重量
@export var WEIGHT: float = 1.0
## 武器使用動畫
@export var ANIM: String = "SwordType"

@export var NAME: String = ""
var is_main: bool = true
var next_weapon: Weapon

func get_weapon_name()-> String:
	var str = ""
	var curr_weapon: Weapon = self
	while curr_weapon.next_weapon:
		curr_weapon = curr_weapon.next_weapon
		str += "[" + curr_weapon.NAME + "]"
	return str + NAME

func get_damage():
	# 武器傷害 + 升級傷害增加
	return DMG + PlayerUpgradeSystem.player_stats.attack_damage

# used by player
func frame_attack(delta: float):
	pass

# used by GodScene
signal on_click(id: String)

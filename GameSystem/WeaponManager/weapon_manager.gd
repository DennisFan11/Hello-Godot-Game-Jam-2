class_name WeaponManager
extends Node2D

func _ready() -> void:
	DI.register("_weapon_manager", self)

var weapon_map = {
	"sword": {
		"scene": preload("uid://b0nre1wp17b5l"),
	},
	"DispellingSword": {
		"scene": preload("uid://bqgvi3j3xs1ku"),
	},
	"GDScript":{
		"scene": preload("uid://bsxrnj083mcwt")
	}
}

func get_random_weapon_id()-> String:
	return "GDScript"
	return "DispellingSword"
	return weapon_map.keys().pick_random()

func create_weapon_scene(id: String)-> Weapon:
	var weapon: Weapon = \
		(weapon_map[id]["scene"] as PackedScene).instantiate()
	weapon.id = id
	printt("create weapon:", id)
	return weapon

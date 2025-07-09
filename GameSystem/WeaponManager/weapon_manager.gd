class_name WeaponManager
extends Node2D

func _ready() -> void:
	DI.register("_weapon_manager", self)

var weapon_map = {
	"sword": {
		"scene": preload("uid://ynmgrxw25he7"),
	}
}

func get_random_weapon_id()-> String:
	return weapon_map.keys().pick_random()

func creat_weapon_scene(id: String)-> Weapon:
	var weapon: Weapon = \
		(weapon_map[id]["scene"] as PackedScene).instantiate()
	weapon.id = id
	return weapon

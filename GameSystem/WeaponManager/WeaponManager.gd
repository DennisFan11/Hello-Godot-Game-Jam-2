extends Node

var weapon_map = {
	"Excalibur":{
		"scene": preload("uid://4vimk1pu87eh")
	},
	"sword": {
		"scene": preload("uid://b0nre1wp17b5l"),
	},
	"BigSword": {
		"scene": preload("uid://creq4ecbuhbfc")
	},
	"DispellingSword": {
		"scene": preload("uid://bqgvi3j3xs1ku"),
	},
	#"GDweapon": {
		#"scene": preload("uid://bsxrnj083mcwt"),
	#},
	"Knife": {
		"scene": preload("uid://dq5iml0qmpxk"),
	},
	"FoldingStool": {
		"scene": preload("uid://qqmdqofjd4xa"),
	},
	"Table": {
		"scene": preload("uid://d15lgghc5vkfi"),
	},
	"Elephant": {
		"scene": preload("uid://m2xsglplvrqa"),
	},
}


func get_random_weapon_id() -> String:
	#return "Excalibur"
	return weapon_map.keys().pick_random()

func create_weapon_scene(id: String) -> Weapon:
	var weapon: Weapon = \
		(weapon_map[id]["scene"] as PackedScene).instantiate()
	weapon.id = id
	printt("create weapon:", id)
	return weapon

func create_random_weapon() -> Weapon:
	return create_weapon_scene(get_random_weapon_id())



func get_player_weapon():
	return DI.get_dependence("_weapon_slot").take_first_weapon()

func set_player_weapon(weapon:Weapon):
	DI.get_dependence("_weapon_slot").set_current_weapon(weapon)

func duplicate_player_weapon():
	return get_player_weapon().duplicate()

extends Node

var weapon_map = {
	"Excalibur": {
		"scene": preload("uid://4vimk1pu87eh"),
	},
	"BrokenSword": {
		"scene": preload("uid://cmknshmdfm2m8"),
	},
	"sword": {
		"scene": preload("uid://b0nre1wp17b5l"),
	},
	"BigSword": {
		"scene": preload("uid://creq4ecbuhbfc"),
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
	"Spear": {
		"scene": preload("uid://cqw8w6knv08b3"),
	},
}


func get_random_weapon_id() -> String:
	return "Spear"
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

func get_player_weapon_count():
	return DI.get_dependence("_weapon_slot").calculate_total_count()

func set_player_weapon(weapon: Weapon):
	DI.get_dependence("_weapon_slot").set_current_weapon(weapon)

func duplicate_player_weapon():
	return get_player_weapon().duplicate()

## NOTE 感覺不會用到的東西
func move_player_weapon(target_node: Node2D, glue_layer: GlueLayer = null, keep_global_transform: bool = true):
	return get_player_weapon().move_to(target_node, glue_layer, keep_global_transform)

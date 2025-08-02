extends Node

var weapon_map = {
	"Excalibur": {
		"scene": preload("uid://4vimk1pu87eh"),
		"can_random": false
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
	"House": {
		"scene": preload("uid://80sgembmigab"),
	},
}

func get_weapon_map_keys() -> Array:
	var list = []
	for id in weapon_map:
		if weapon_map[id].get("can_random", true):
			list.append(id)
	print(list)
	return list

func get_random_weapon_id() -> String:
	#return "Spear"
	return get_weapon_map_keys().pick_random()

func get_random_weapon_id_list(num:int = 2, exclude:Array = []) -> Array:
	var id_list:Array = get_weapon_map_keys()
	var result:Array = []

	for id in exclude:
		id_list.erase(id)

	while num > 0:
		var index = randi_range(0, len(id_list))
		result.append(id_list[index])
		id_list.pop_at(index)
		num -= 1
	return result

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

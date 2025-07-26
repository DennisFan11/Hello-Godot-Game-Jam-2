class_name UpgradeLevel
extends SaveResource

var default_icon = "🔧"

var config_dict:Dictionary = {
	"HEALTH": {
		"icon": "❤️",
		"name": "生命值強化",
		"description": "增加最大生命值",
		"stats": "max_health",
		"base_value": 20,
		"max_level": 10,
		"cost": 1
	},
	"ATTACK": {
		"icon": "⚔️",
		"name": "攻擊力強化",
		"description": "增加攻擊傷害",
		"stats": "attack_damage",
		"base_value": 5,
		"max_level": 8,
		"cost": 1
	},
	"SPEED": {
		"icon": "💨",
		"name": "移動速度強化",
		"description": "增加移動速度",
		"stats": "move_speed",
		"base_value": 15.0,
		"max_level": 6,
		"cost": 1
	},
	"JUMP": {
		"icon": "🦘",
		"name": "跳躍力強化",
		"description": "增加跳躍高度",
		"stats": "jump_power",
		"base_value": 30.0,
		"max_level": 5,
		"cost": 1
	},
	"COOLDOWN_REDUCTION": {
		"icon": "⏰",
		"name": "技能冷卻縮減",
		"description": "減少技能冷卻時間",
		"stats": "skill_cooldown_reduction",
		"base_value": 0.1,
		"max_level": 5,
		"cost": 2
	}
}

var point = 0
var level_dict:Dictionary = {}



func get_data():
	return {
		"point": point,
		"level_dict": level_dict
	}

func set_data(data):
	point = data.get("point", point)
	level_dict = data.get("level_dict", level_dict)



func get_upgrade_type():
	return config_dict.keys()

func get_config(upgrade_type):
	return config_dict.get(upgrade_type)

func set_upgrade_point(value):
	point = value

func add_upgrade_point(value):
	point += value

func get_upgrade_point():
	return point

func set_level(upgrade_type, value):
	level_dict.set(upgrade_type, value)

func add_level(upgrade_type, value):
	set_level(upgrade_type, get_level(upgrade_type) + value)

func get_level(upgrade_type):
	return level_dict.get(upgrade_type, 0)

func get_upgrade_info(upgrade_type):
	return config_dict.get(upgrade_type).merged({
		"icon": default_icon,
		"current_level": get_level(upgrade_type),
		"can_upgrade": can_upgrade(upgrade_type)
	})



func can_upgrade(upgrade_type:String, count:int = 1) -> int:
	if not upgrade_type in config_dict \
	or count <= 0:
		return 0
	var config = get_config(upgrade_type)

	var can_upgrade_level = config.max_level - get_level(upgrade_type)
	if can_upgrade_level == 0:
		return 0
	if can_upgrade_level < count:
		count = can_upgrade_level
	
	can_upgrade_level = point / config.cost
	if can_upgrade_level > count:
		return count

	return can_upgrade_level

func try_upgrade(upgrade_type:String, count:int = 1) -> int:
	count = can_upgrade(upgrade_type)
	if count > 0:
		add_upgrade_point(-get_config(upgrade_type).cost * count)
		add_level(upgrade_type, count)

	return count

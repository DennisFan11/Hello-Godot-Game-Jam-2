class_name PlayerStats
extends SaveResource

var max_health: int = 200
var current_health: int = 200
var attack_damage: int = 10
var move_speed: float = 100.0
var jump_power: float = 200.0
var skill_cooldown_reduction: float = 0.0
var experience_points: int = 0
var level: int = 1



func get_data():
	return {
		"max_health": max_health,
		"current_health": current_health,
		"attack_damage": attack_damage,
		"move_speed": move_speed,
		"jump_power": jump_power,
		"skill_cooldown_reduction": skill_cooldown_reduction,
		"experience_points": experience_points,
		"level": level
	}

func set_data(data):
	max_health = data.get("max_health", max_health)
	current_health = data.get("current_health", current_health)
	attack_damage = data.get("attack_damage", attack_damage)
	move_speed = data.get("move_speed", move_speed)
	jump_power = data.get("jump_power", jump_power)
	skill_cooldown_reduction = data.get("skill_cooldown_reduction", skill_cooldown_reduction)
	experience_points = data.get("experience_points", experience_points)
	level = data.get("level", level)



func set_stats(name, value):
	var old_value = get(name)
	if value != old_value:
		set(name, value)
		emit_changed()

func add_stats(name, value):
	set_stats(name, get(name) + value)

func get_stats(name):
	return get(name)

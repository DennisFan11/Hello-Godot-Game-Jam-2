class_name PlayerStats
extends Resource

@export var max_health: int = 100
@export var current_health: int = 100
@export var attack_damage: int = 10
@export var move_speed: float = 100.0
@export var jump_power: float = 200.0
@export var skill_cooldown_reduction: float = 0.0
@export var experience_points: int = 0
@export var level: int = 1



func set_stats(name, value):
	var old_value = get(name)
	if value != old_value:
		set(name, value)
		emit_changed()

func add_stats(name, value):
	set_stats(name, get(name) + value)

func get_stats(name):
	return get(name)

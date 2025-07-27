class_name WeaponMove
extends Action

@export var initial_angle:int = -135

@export var speed:float = 1.0

signal move_started
signal move_ended



func init_move(weapon_slot:Node2D):
	pass

func start_move(weapon_slot:Node2D, time:float):
	target.start_attack()
	move_started.emit(weapon_slot, time)

func end_move(weapon_slot):
	target.end_attack()
	move_ended.emit(weapon_slot)

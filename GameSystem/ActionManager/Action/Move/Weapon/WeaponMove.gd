class_name WeaponMove
extends Action

@export var initial_angle:int = -135

signal move_started
signal move_ended



func init_move(target:Node2D):
	pass

func start_move(target:Node2D, time:float):
	move_started.emit(target, time)

func end_move(target):
	move_ended.emit(target)

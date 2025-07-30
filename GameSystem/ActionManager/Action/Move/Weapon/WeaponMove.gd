class_name WeaponMove
extends Action

@export var initial_angle:int = -135

@export var speed:float = 1.0

@export var mouse_control:bool = true

@export var ease_type:Tween.EaseType = Tween.EASE_OUT
@export var trans_type:Tween.TransitionType = Tween.TRANS_BACK

var _player_manager:PlayerManager
#var _weapon_slot:WeaponSlot

signal move_started
signal move_ended



func point_to_mouse(weapon_slot):
	if not mouse_control:
		return
	if not target or target.get("in_attack"):
		return
	weapon_slot.rotation = get_mouse_vec().angle() + deg_to_rad(initial_angle)

func init_move(weapon_slot:Node2D):
	point_to_mouse(weapon_slot)

func start_move(weapon_slot:Node2D, time:float):
	target.start_attack()
	move_started.emit(weapon_slot, time)

func end_move(weapon_slot):
	target.end_attack()
	move_ended.emit(weapon_slot)



func get_mouse_vec():
	return _player_manager.get_mouse_vec()

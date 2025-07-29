class_name SwordMove
extends WeaponMove

@export var swing_angle:int = 180
@export var ease_type:Tween.EaseType = Tween.EASE_OUT
@export var trans_type:Tween.TransitionType = Tween.TRANS_BACK


func init_move(weapon_slot:Node2D):
	weapon_slot.rotation_degrees = initial_angle
	

func start_move(weapon_slot:Node2D, time:float):
	time /= speed

	var tween = create_tween()
	tween.set_ease(ease_type).set_trans(trans_type)
	tween.tween_property(weapon_slot, "rotation_degrees", get_end_angle(), time)
	tween.tween_callback(end_move.bind(weapon_slot))
	super(weapon_slot, time)

func end_move(weapon_slot):
	super(weapon_slot)
	
	if weapon_slot:
		var move_manager = %MoveManager
		if move_manager.next_phase():
			var action = move_manager.get_enable_action()
			if action:
				action[0].init_move(weapon_slot)
		else:
			init_move(weapon_slot)

func get_end_angle() -> int:
	return initial_angle + swing_angle

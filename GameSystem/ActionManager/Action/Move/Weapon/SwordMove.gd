class_name SwordMove
extends WeaponMove

@export var swing_angle:int = 180

func init_move(weapon_slot:Node2D):
	weapon_slot.rotation_degrees = initial_angle
	

func start_move(weapon_slot:Node2D, time:float):
	target.start_attack()
	printt(target, self, weapon_slot, time)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(weapon_slot, "rotation_degrees", get_end_angle(), time)
	tween.tween_callback(end_move.bind(weapon_slot))
	super(weapon_slot, time)

func end_move(weapon_slot):
	target.end_attack()
	
	var move_manager = %MoveManager
	if move_manager.next_phase():
		var action = move_manager.get_enable_action()
		if action:
			action[0].init_move(weapon_slot)
	else:
		init_move(weapon_slot)
	super(weapon_slot)

func get_end_angle() -> int:
	return initial_angle + swing_angle

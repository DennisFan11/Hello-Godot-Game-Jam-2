class_name SpearMove
extends WeaponMove

@export var move_distance:float = 50.0

func init_move(weapon_slot:Node2D):
	weapon_slot.rotation_degrees = initial_angle
	super(weapon_slot)

func start_move(weapon_slot:Node2D, time:float):
	time /= 2
	time /= speed

	var tween = create_tween()
	tween.set_ease(ease_type).set_trans(trans_type)

	tween.tween_property(weapon_slot, "position", get_end_pos(weapon_slot), time)
	tween.tween_property(weapon_slot, "position", Vector2.ZERO, time)

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

func get_end_pos(weapon_slot:Node2D):
	return weapon_slot.position + get_mouse_vec() * move_distance

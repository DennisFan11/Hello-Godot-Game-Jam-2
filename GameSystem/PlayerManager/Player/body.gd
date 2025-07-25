extends Node2D


var step_sound = preload("uid://co2t0h358j0px")
func _ready() -> void:
	$RLeg.can_move = false
	$LLeg.can_move = true
	$LLeg.moved.connect(
		func ():
			if %ClimbRaycast.is_colliding():
				SoundManager.play_stream_sound(step_sound, $LLeg.global_position, 0.5)
			await get_tree().create_timer(0.1).timeout
			$RLeg.can_move = true
	)
	$RLeg.moved.connect(
		func ():
			if %ClimbRaycast.is_colliding():
				SoundManager.play_stream_sound(step_sound, $RLeg.global_position, 0.5)
			await get_tree().create_timer(0.1).timeout
			$LLeg.can_move = true
	)
	




func _process(delta: float) -> void:
	$RLeg.set_target(get_raycast_point(%RRayCast2D))
	$LLeg.set_target(get_raycast_point(%LRayCast2D))
		

func get_raycast_point(node: RayCast2D):
	return node.get_collision_point() \
		if node.is_colliding() else\
		node.to_global(node.target_position)

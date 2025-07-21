extends Node2D




func _process(delta: float) -> void:
	$RLeg.set_target(get_raycast_point(%RRayCast2D))
	$LLeg.set_target(get_raycast_point(%LRayCast2D))
		

func get_raycast_point(node: RayCast2D):
	return node.get_collision_point() \
		if node.is_colliding() else\
		node.to_global(node.target_position)

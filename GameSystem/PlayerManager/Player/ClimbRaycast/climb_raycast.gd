class_name ClimbRaycast
extends Node2D

const MOUNT: int = 30
const DISTANCE: float = 35.0

var _raycast_arr: Array[RayCast2D] = []
func _ready() -> void:
	for i in range(MOUNT):
		var angle = i* (PI*2.0/MOUNT)
		_raycast_arr.append(
			_create_raycast( Vector2.from_angle(angle)*DISTANCE )
		)

func _create_raycast(vec: Vector2)-> RayCast2D:
	var raycast := RayCast2D.new()
	raycast.target_position = vec
	raycast.set_collision_mask_value(1, false)
	raycast.set_collision_mask_value(20, true)
	add_child(raycast)
	return raycast


func _physics_process(delta: float) -> void:
	pass

func get_closet_point()-> Vector2:
	var colliding_points: Array[Vector2] = []
	for i in _raycast_arr:
		if i.is_colliding():
			colliding_points.append(i.get_collision_point())
	
	return Utility.min_custom(
		colliding_points,
		func (A: Vector2, B: Vector2):
			return A.length() < B.length()
	)
	
func is_colliding()-> bool:
	for i in _raycast_arr:
		if i.is_colliding():
			return true
	return false












#

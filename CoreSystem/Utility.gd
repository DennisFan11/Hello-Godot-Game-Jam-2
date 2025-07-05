#class_name Utility
extends Node2D





func min_custom(array: Array, com: Callable):
	if array.is_empty():
		return null
	
	var min_value = array[0]
	for i in range(1, array.size()):
		if com.call(array[i], min_value):
			min_value = array[i]
	return min_value


## 2D 物理空間查詢 返回碰撞的節點列表
func collide_query_polygon( 
	global_polygon:PackedVector2Array,
	mask:int
	)-> Array[Node2D]:
		
	var shape_rid = PhysicsServer2D.convex_polygon_shape_create() # 凸多邊形
	PhysicsServer2D.shape_set_data(shape_rid, global_polygon)

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape_rid = shape_rid
	params.collide_with_areas = false
	params.collide_with_bodies = true
	params.collision_mask = mask
	
	var result: Array[Node2D] = []
	for i in get_world_2d().direct_space_state.intersect_shape(params):
		result.append(i["collider"])
	
	PhysicsServer2D.free_rid(shape_rid)
	return result



func collide_query_circle( 
	pos: Vector2,
	R: float,
	mask: int
	)-> Array[Node2D]:
		
	var shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, R)

	var params = PhysicsShapeQueryParameters2D.new()
	params.transform = Transform2D(0, pos) # 設定位置
	params.shape_rid = shape_rid
	params.collide_with_areas = false
	params.collide_with_bodies = true
	params.collision_mask = mask
	
	var result: Array[Node2D] = []
	for i in get_world_2d().direct_space_state.intersect_shape(params):
		result.append(i["collider"])
	
	PhysicsServer2D.free_rid(shape_rid)
	return result



func raycast(from: Vector2, to: Vector2, exclude: Array = [], collision_mask: int = 0x7FFFFFFF) -> Dictionary:
	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(from, to, collision_mask, exclude)
	)

#

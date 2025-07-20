class_name TerrainManager
extends Node2D

const BLOCK_SIZE:Vector2 = Vector2(100.0, 100.0)

@export var _map_data: Array = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		DI.register("_terrain_manager", self)
	DestroyableBlock._terrain_manager = self
	TerrainEditor._terrain_manager = self
	Brush._terrain_manager = self
	DestroyableBlock.BlockSize = BLOCK_SIZE
	load_map()



#region DestroyableBlock 操作區域

func add_DestroyableBlock( node:DestroyableBlock ):
	%TerrainShader.add_child(node) 

## 對當前地圖上的地形進行切割
func clip( global_polygon:PackedVector2Array ):
	_clip( global_polygon )

## (高壓場景專用)
func clip_after( global_polygon:PackedVector2Array ):
	_clip_after( global_polygon )


## NOTE 合併所有相同id物件, 並切割不同id物件, 時間過後自分裂
func merge( global_polygon:PackedVector2Array, id:int ):
	_merge( global_polygon, id)

#endregion End of DestroyableBlock 操作區域

## 更新 TerrainData
func save_map():
	_map_data = []
	for i:DestroyableBlock in %TerrainShader.get_children():
		_map_data.append(i.Save())
	

func load_map():
	
	## clear map
	for i:DestroyableBlock in %TerrainShader.get_children():
		if is_instance_valid(i): i.queue_free()
	
	for data in _map_data:
		DestroyableBlock.Load(data)
		
	
	
	










#========================================內部實作========================================







#region 地形操作相關實做區域

func _clip( global_polygon:PackedVector2Array ):
	for i in _get_collide_bodies(global_polygon):
		if i.is_in_group("Block"):
			var block:DestroyableBlock = i.get_parent()
			block.Clip(global_polygon)

func _clip_after( global_polygon:PackedVector2Array ):
	for i in _get_collide_bodies(global_polygon):
		if i.is_in_group("Block"):
			var block:DestroyableBlock = i.get_parent()
			block.After_Optimize_Clip(global_polygon)


func _merge( global_polygon:PackedVector2Array, id:int ):
	var marge_node:DestroyableBlock = null
	var bodies:Array[Node2D] = _get_collide_bodies(global_polygon)
	
	#for i in range(bodies.size()): # WARNING 導致 Bug
		#if bodies[i].is_in_group("Block") and bodies[i].get_parent().ID == id:
			#marge_node = bodies.pop_at(i).get_parent()
			#marge_node.Merge(global_polygon)
			#break
	if !marge_node: # 相同id實例不存在
		marge_node = DestroyableBlock.new(id, _get_GridPos_from_polygon(global_polygon), global_polygon)
		add_DestroyableBlock(marge_node)
		marge_node.Merge(PackedVector2Array()) ### NOTE 手動觸發自分裂
		
	for i in bodies:
		
		if i.is_in_group("Block"):
			var block:DestroyableBlock = i.get_parent()
			if block.ID == id:
				await marge_node.Merge(block.Polygon)
				block.queue_free() 
			else:
				block.Clip(global_polygon)
#endregion






#--------------------------工具函數---------------------------


## 推算網格座標
func _get_GridPos_from_polygon( global_polygon:PackedVector2Array )-> Vector2:
	var center:Vector2
	for i in global_polygon:
		center += i
	center /= global_polygon.size()
	return (center/BLOCK_SIZE).floor()

## 2D 物理空間查詢 返回碰撞的節點列表
func _get_collide_bodies( global_polygon:PackedVector2Array )-> Array[Node2D]:
	var shape_rid = PhysicsServer2D.convex_polygon_shape_create() # 凸多邊形
	PhysicsServer2D.shape_set_data(shape_rid, global_polygon)

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape_rid = shape_rid
	params.collide_with_areas = false
	params.collide_with_bodies = true
	
	var result: Array[Node2D] = []
	for i in get_world_2d().direct_space_state.intersect_shape(params):
		result.append(i["collider"])
	
	PhysicsServer2D.free_rid(shape_rid)
	return result

@tool
class_name TerrainManager
extends Node2D

const BLOCK_SIZE:Vector2 = Vector2(50.0, 50.0)

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
	node.Valid_check()

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
		
func clear():
	_map_data = []
	load_map()
	
	










#========================================內部實作========================================







#region 地形操作相關實做區域

func _clip( global_polygon:PackedVector2Array ):
	for block in _get_collide_bodies(global_polygon):
		block.Clip(global_polygon)

func _clip_after( global_polygon:PackedVector2Array ):
	for block in _get_collide_bodies(global_polygon):
		block.After_Optimize_Clip(global_polygon)


func _merge( global_polygon:PackedVector2Array, id:int ):
	var marge_node:DestroyableBlock = null
	var bodies:Array = _get_collide_bodies(global_polygon)
	
	if !marge_node: # 相同id實例不存在
		
		## NOTE this is magic
		var PosId = _get_GridPos_from_polygon(global_polygon) \
			if not Engine.is_editor_hint() \
			else (get_global_mouse_position()/BLOCK_SIZE).floor()
		
		marge_node = DestroyableBlock.new(id, PosId, global_polygon)
		add_DestroyableBlock(marge_node)
		marge_node.Merge(PackedVector2Array()) ### NOTE 手動觸發自分裂
		
	for block in bodies:
		if block.ID == id:
			
			# FIXME 相交檢測
			
			if not Geometry2D.intersect_polygons(marge_node.Polygon, block.Polygon):
				continue
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
func _get_collide_bodies( global_polygon:PackedVector2Array )-> Array:
	if Engine.is_editor_hint():
		return _editor_get_collide_bodies( global_polygon )
	
	var shape_rid = PhysicsServer2D.convex_polygon_shape_create() # 凸多邊形
	PhysicsServer2D.shape_set_data(shape_rid, global_polygon)

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape_rid = shape_rid
	params.collide_with_areas = false
	params.collide_with_bodies = true
	
	var result: Array[DestroyableBlock] = []
	for i in get_world_2d().direct_space_state.intersect_shape(params):
		var node = i["collider"]
		if node.is_in_group("Block"):
			var block:DestroyableBlock = node.get_parent()
			result.append(block)
	
	PhysicsServer2D.free_rid(shape_rid)
	return result


## =========== FOR EDITOR ========

var _destroyable_block_map: Dictionary[Vector2, Array]
func _editor_get_collide_bodies(global_polygon: PackedVector2Array) -> Array:
	var result: Array = []
	var visited := {}
	var collide_polygon := Geometry2D.offset_polygon(global_polygon, BLOCK_SIZE.x*3.0, Geometry2D.JOIN_ROUND)[0]
	
	
	var bounding_box: Array = GeometryTool.get_block_bounding_box(global_polygon, BLOCK_SIZE)
	var start: Vector2 = bounding_box[0] - Vector2.ONE * 2.0
	var end: Vector2 = bounding_box[1] + Vector2.ONE * 2.0

	# 遍歷 bounding box 內的每個格子中心點，若在 polygon 內則取出對應的 block
	for x in range(start.x, end.x+1):
		for y in range(start.y, end.y+1):
			var cell_center := BLOCK_SIZE * Vector2(x, y) # + Vector(0.5, 0.5)
			if Geometry2D.is_point_in_polygon(cell_center, collide_polygon) or true: # TEST
				var pos_id := Vector2(x, y)
				if visited.has(pos_id):
					continue
				visited[pos_id] = true
				if _destroyable_block_map.has(pos_id):
					result.append_array(_destroyable_block_map[pos_id])

	return result

func _block_register(block: DestroyableBlock):
	#print("register block in", block.PosID)
	if not _destroyable_block_map.has(block.PosID):
		_destroyable_block_map[block.PosID] = []
	_destroyable_block_map[block.PosID].append(block)

func _block_unregister(block: DestroyableBlock):
	_destroyable_block_map[block.PosID].erase(block)












#

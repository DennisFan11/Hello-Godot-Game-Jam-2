@tool
class_name DestroyableBlock
extends Node2D


var _base_scene:DestoryableBlockBaseScene
## 分塊大小用於自動切割
static var BlockSize: Vector2

var Busy:bool = false

var ID:int:
	set(new):
		ID = new
		if _base_scene: _base_scene.ID = new
var PosID:Vector2: # FIXME 調整為基於 BlockSize ID
	set(new):
		PosID = new
		if _base_scene: _base_scene.Position = new * BlockSize
var Polygon:PackedVector2Array:
	set(new):
		#if Geometry2D.triangulate_polygon(new).size() == 0:
			#print("Triangulate Failed")
			#queue_free()
			#return
		#new = Geometry2D.convex_hull(new)
		Polygon = new
		if _base_scene: _base_scene.Polygon = new

#region Palette


func Save()-> Dictionary:
	return {
		"id": ID,
		"pos_id": PosID,
		"polygon": Polygon
	}
static func Load(data: Dictionary):
	_terrain_manager.add_DestroyableBlock(
		DestroyableBlock.new(
			data["id"], 
			data["pos_id"], 
			data["polygon"]
			)
	)

func Valid_check():
	var square: Array[Vector2] = [
		Vector2(PosID),
		Vector2(PosID) + Vector2(1, 0),
		Vector2(PosID) + Vector2(1, 1),
		Vector2(PosID) + Vector2(0, 1),
	]
	for pos: Vector2 in Polygon:
		if not Geometry2D.is_point_in_polygon(pos/BlockSize, square):
			_set_split_timer()
			return
	if PosID != _terrain_manager._get_GridPos_from_polygon(Polygon):
		_set_split_timer()
	


#endregion


## 創建新的實例
func _init(_id:int, _PosID:Vector2, _polygon:PackedVector2Array) -> void:
	ID = _id; PosID = _PosID; Polygon = _polygon
	var node := VisibleOnScreenNotifier2D.new()
	add_child(node)
	
	_spawn_base_scene()
	node.screen_entered.connect(_spawn_base_scene)
	node.screen_exited.connect( _free_base_scene)
	node.position = _PosID* BlockSize
	node.rect = Rect2(Vector2.ONE * -100, Vector2.ONE * 200)
	node.visible = false
	_editor_register()


func _editor_register():
	_terrain_manager._block_register(self)
	
func _editor_unregister():
	_terrain_manager._block_unregister(self)

func _exit_tree() -> void:
	_editor_unregister()



func _spawn_base_scene():
	if _base_scene:
		return
	_free_base_scene()
	var file := preload("uid://chs71krydajvg")
	_base_scene = file.instantiate()
	add_child(_base_scene)
	ID = ID; PosID = PosID; Polygon = Polygon
func _free_base_scene():
	if _base_scene: 
		_base_scene.queue_free()
		_base_scene = null


func Clip(global_polygon:PackedVector2Array)-> float:
	var value = _clip(global_polygon)
	return value

func Merge(global_polygon:PackedVector2Array)-> float:
	var value = await _merge(global_polygon)
	#print("merge ", value)
	return value

func After_Optimize_Clip(global_polygon:PackedVector2Array)-> float:
	var value = _after_optimize_clip(global_polygon)
	return value



static var _terrain_manager: TerrainManager

#region  實作

#region Tools (to_global, to_local, _group_spawn)

func _group_spawn(id:int, pos:Vector2, global_polygon_arr:Array[PackedVector2Array]):
	for global_polygon:PackedVector2Array in global_polygon_arr:
		var new_block := DestroyableBlock.new(id, pos, global_polygon)
		_terrain_manager.add_DestroyableBlock(new_block)
#endregion


var _split_timer:Timer
var _optimize_timer:Timer

func _gen_timers():
	_split_timer = Timer.new()
	add_child(_split_timer)
	_split_timer.timeout.connect(_self_split)
	_split_timer.one_shot = true
	
	_optimize_timer = Timer.new()
	add_child(_optimize_timer)
	_optimize_timer.timeout.connect(_self_optimize)
	_optimize_timer.one_shot = true


func _set_split_timer():
	if _split_timer:
		_split_timer.start(1.0)
	else:
		_gen_timers()
func _set_optimize_timer():
	if _optimize_timer:
		_optimize_timer.start(1.0)
	else:
		_gen_timers()



func _self_split(): # 區塊優化w
	print("Self Split !!!")
	var BLOCK_SIZE = BlockSize.x
	var arr_pos = []
	var arr_poly:Array[PackedVector2Array] = [] # global polygon arr
	
	var bounding_box: Array = GeometryTool.get_block_bounding_box(Polygon, BlockSize)
	var start: Vector2 = bounding_box[0] - Vector2.ONE
	var end: Vector2 = bounding_box[1] + Vector2.ONE
	
	for x in range(start.x, end.x+1): # 初始化 座標及多邊形陣列
		for y in range(start.y, end.y+1):
			var pos = Vector2(x,y)*BLOCK_SIZE # + PosID*BlockSize
			arr_pos.append(Vector2(x,y))
			arr_poly.append(PackedVector2Array([
				Vector2(pos.x,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y+BLOCK_SIZE),
				Vector2(pos.x,pos.y+BLOCK_SIZE)
			]))
	# 相交生成
	for i in range(arr_pos.size()):
		var need_polygons = Geometry2D.intersect_polygons(Polygon, arr_poly[i])
		_group_spawn(ID, arr_pos[i], need_polygons) # ATTENTION FIXME
	queue_free()
	return

var last_origin:PackedVector2Array = []
func _self_optimize():
	Polygon = (GeometryTool.VertexOptimization(Polygon, last_origin, BlockSize))
	last_origin = []

func _clip(global_polygon:PackedVector2Array)-> float:
	var origin = Polygon
	var clipped := Geometry2D.clip_polygons(origin, global_polygon)
	if clipped.size() == 0:
		queue_free()
		return GeometryTool.Calculate_polygon_area(origin, global_polygon)
	
	for i in range(clipped.size()):# 全體頂點優化
		clipped[i] = GeometryTool.VertexOptimization(clipped[i], origin, BlockSize)
	clipped = GeometryTool.Merge_hole_polygon(clipped) # 合併有孔多邊形
	Polygon = (clipped.pop_front()) # 重設自身多邊形
	_group_spawn(ID, PosID, clipped) # 實例化剩餘多邊形
	return GeometryTool.Calculate_polygon_area(origin, global_polygon) # 面積計算

func _merge(global_polygon:PackedVector2Array)->float:
	
	### ATTENTION Self Split timer start
	_set_split_timer()
	
	var origin = Polygon
	var merged = Geometry2D.merge_polygons(origin, global_polygon)
	if merged.size() == 0:
		#assert(false)
		queue_free()
		return GeometryTool.Calculate_polygon_area(origin, global_polygon)
	
	#for i in range(merged.size()):# 全體頂點優化
		#merged[i] = VertexOptimization(merged[i], origin, BlockSize)
	
	
	
	
	var this_poly = merged.pop_front()
	await _group_spawn(ID, PosID, merged) # 實例化剩餘多邊形

	### BUG 沒有帶孔多邊形合併
	Polygon = this_poly # 重設自身多邊形
	
	
	
	return GeometryTool.Calculate_polygon_area(origin, global_polygon) # 面積計算

func _after_optimize_clip(global_polygon:PackedVector2Array)-> float: # TEST 高壓場景用
	Busy = true
	var origin = Polygon
	var clipped = Geometry2D.clip_polygons(origin, global_polygon)
	if clipped.size() == 0:
		queue_free()
		return GeometryTool.Calculate_polygon_area(origin, global_polygon)
	clipped = GeometryTool.Merge_hole_polygon(clipped) # 合併有孔多邊形
	Polygon = (clipped.pop_front()) # 重設自身多邊形
	_group_spawn(ID, PosID, clipped) # 實例化剩餘多邊形
	
	### ATTENTION Self optimize timer start
	if last_origin.size() == 0:
		last_origin = origin
	_set_optimize_timer()
		
	Busy = false
	
	return GeometryTool.Calculate_polygon_area(origin, global_polygon) # 面積計算

#endregion

#

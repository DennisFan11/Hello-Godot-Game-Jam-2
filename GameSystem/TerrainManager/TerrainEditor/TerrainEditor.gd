@tool
class_name TerrainEditor
extends Node2D

@export_tool_button("啟用繪圖工具") var start = start_draw
@export_tool_button("關閉繪圖工具") var end = end_draw


static var _terrain_manager: TerrainManager


var _brush: Brush
func start_draw():
	if is_instance_valid(_brush): _brush.queue_free()
	_brush = preload("uid://b3o1wbiuujhmc").instantiate()
	add_child(_brush)
func end_draw():
	if is_instance_valid(_brush): _brush.queue_free()

func save():
	_terrain_manager.save_map()

@tool
class_name TerrainEditor
extends Node2D



@export_tool_button("啟用繪圖工具") var start = start_draw
@export_tool_button("關閉繪圖工具") var end = end_draw

@export_range(10, 2000, 2)
var Radius: float = 50:
	set(new):
		Radius = new
		if _brush: _brush.Radius = new

@export
var Shape: Brush.SHAPE = Brush.SHAPE.CIRCLE:
	set(new):
		Shape = new
		if _brush: _brush.Shape = new

@export 
var ID: int = 1:
	set(new):
		ID = new
		if _brush: _brush.ID = new

@export
var Type: Brush.TYPE = Brush.TYPE.POINT:
	set(new):
		Type = new
		if _brush: _brush.Type = new




func _update_data():
	Radius = Radius
	Shape = Shape
	ID = ID 
	Type = Type


@export_category("存檔工具")
@export_tool_button("保存") var _save = save
@export_tool_button("全部清除") var _clear = clear



var _brush: Brush
static var _terrain_manager: TerrainManager


var _input_plugin: InputPlugin

func start_draw():
	if is_instance_valid(_brush): _brush.queue_free()
	_brush = preload("uid://b3o1wbiuujhmc").instantiate()
	_brush.set_input_plugin(_input_plugin)
	add_child(_brush)
	_update_data()
	
func end_draw():
	if is_instance_valid(_brush): 
		_brush.queue_free()
	_brush = null

func save():
	_terrain_manager.save_map()

func clear():
	_terrain_manager.clear()

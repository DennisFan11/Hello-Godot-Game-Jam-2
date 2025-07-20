@tool
class_name Brush 
extends FSM_Mouse


func set_input_plugin(input_plugin: InputPlugin):
	input_plugin.input_event.connect(_editor_input)



### NOTE : BlockDrawingTool 圓形繪製工具Class
### 圖形預設為圓形 由_gen_points生成 可覆寫
### 左鍵添加, 右鍵刪除 shift連線

enum SHAPE {CIRCLE, SQUARE}
enum TYPE {POINT, LINE, BOX}

var ID:int = 1
var Radius:float = 70.0
var Shape:SHAPE = SHAPE.CIRCLE
var PointSize:float = 20
var Type:TYPE = TYPE.POINT


#region point Tools
func _gen_points(offset: Vector2)->PackedVector2Array:
	match Shape:
		SHAPE.CIRCLE:
			var arr:PackedVector2Array = []
			for i in range(PointSize):
				var angle:float = (i/PointSize) * 2*PI
				arr.append(offset + Radius * Vector2(cos(angle),  sin(angle)) )
			return arr
		SHAPE.SQUARE:
			var arr:PackedVector2Array = [
				offset + Vector2(-Radius, -Radius),
				offset + Vector2(Radius, -Radius),
				offset + Vector2(Radius, Radius),
				offset + Vector2(-Radius, Radius)
			]
			return arr
	return []

func _sort_points(array:Array)->PackedVector2Array: # 計算順時針多邊形
	"""
	// 輸入: 2點座標 (全域座標)
	輸出: 順時針多邊形 points
	"""
	var cp = Vector2.ZERO
	for i in array:
		cp+=i
	cp/=array.size()
	var center_angle_sort = func(A:Vector2,B:Vector2) -> bool: # 中心最大角度排序 lambda (順時鐘)
		if (A-cp).angle()>=(B-cp).angle():
			return false
		return true
	array.sort_custom(center_angle_sort)# (順時鐘排序)
	return PackedVector2Array(array)

func _gen_line_points(offsetA:Vector2, offsetB:Vector2)-> PackedVector2Array:
	var shapeA = _gen_points(offsetA)
	var shapeB = _gen_points(offsetB)
	var final = []
	for pos in shapeA:
		var a = pos - offsetA
		var b = offsetB - offsetA
		if a.dot(b) < 0.0:
			final.append(pos)
	for pos in shapeB:
		var a = pos - offsetB
		var b = offsetA - offsetB
		if a.dot(b) < 0.0:
			final.append(pos)
	return _sort_points(final)
#endregion



var _first_point:Vector2 = Vector2.ZERO
var _second_point:Vector2 = Vector2.ZERO

func _L_click(): # exec-once
	%HintPolygon2D.color = _color_map[COLOR.BUILD]
	_first_point = get_global_mouse_position()

func _L_clicking():
	_second_point = get_global_mouse_position()
	update_hint_polygon()
	if Type == TYPE.POINT:
		#if not MapManager.merge_busy:
			_terrain_manager.merge(_gen_points(_second_point), ID)

func _L_finish(): #exec-once
	if Type == TYPE.LINE:
		#if not MapManager.merge_busy:
			_terrain_manager.merge(_gen_line_points(_first_point, _second_point), ID)


func _Idle(): # 未按下
	%HintPolygon2D.color = _color_map[COLOR.IDLE]
	_first_point = get_global_mouse_position()
	_second_point = get_global_mouse_position()
	update_hint_polygon()


func _R_click(): # exec-once
	%HintPolygon2D.color = _color_map[COLOR.DELETE]
	_first_point = get_global_mouse_position()

func _R_clicking():
	_second_point = get_global_mouse_position()
	update_hint_polygon()
	if Type == TYPE.POINT:
		_terrain_manager.clip(_gen_points(_second_point))

func _R_finish(): #exec-once
	if Type == TYPE.LINE:
		_terrain_manager.clip(_gen_line_points(_first_point, _second_point))



enum COLOR {DELETE, BUILD, IDLE}
var _color_map = {
	COLOR.DELETE:Color.INDIAN_RED,
	COLOR.BUILD:Color.BEIGE,
	COLOR.IDLE:Color.AQUAMARINE
}

static var _terrain_manager: TerrainManager




func update_hint_polygon():
	match Type:
		TYPE.LINE:
			%HintPolygon2D.polygon = _gen_line_points(_first_point, _second_point)
		TYPE.POINT:
			%HintPolygon2D.polygon = _gen_points(_second_point)
	




#

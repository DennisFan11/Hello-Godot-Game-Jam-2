@tool
class_name FBRIK
extends Node2D



@export var FBRIK_nodes: Array[FBRIK_node] = []
var _points: PackedVector2Array = [Vector2.ZERO]

func get_points()-> PackedVector2Array: 
	return _points


const STEP_LENGTH = 7.0
var _global_target: Vector2
func set_target(target: Vector2)-> void:
	if (target-_points[-1]).length() > STEP_LENGTH:
		_global_target = target






func _process(delta: float) -> void:
	if FBRIK_nodes.size() < 3: return 
	_arr_alignment()
	
	for i in range(3):
		FABRIK_I( _global_target if not Engine.is_editor_hint() else %EndMarker.global_position)
		FABRIK_F( %StartMarker.global_position )
		
	%HintLine.global_position = Vector2.ZERO
	%HintLine.global_rotation = 0.0
	%HintLine.points = _points


func _arr_alignment():
	_points.resize(FBRIK_nodes.size())


func FABRIK_F(pos:Vector2):  # 正向
	var arr:PackedVector2Array = _points
	arr[0] = pos
	for i in range(1, arr.size()):
		var dist: float = FBRIK_nodes[i].Distance if FBRIK_nodes[i] else 10
		arr[i] = _relenght(arr[i] - arr[i-1], dist) + arr[i-1]
	_points = arr

func FABRIK_I(pos:Vector2):  # 反向
	var arr:PackedVector2Array = _points
	arr[-1] = pos
	for i in range(arr.size() - 2, -1, -1): # 反向
		var dist: float = FBRIK_nodes[i].Distance if FBRIK_nodes[i] else 10
		arr[i] = _relenght(arr[i] - arr[i+1], dist) + arr[i+1]
	_points = arr



func _relenght(vec: Vector2, new_length: float)-> Vector2:
	return vec.normalized() * new_length




#

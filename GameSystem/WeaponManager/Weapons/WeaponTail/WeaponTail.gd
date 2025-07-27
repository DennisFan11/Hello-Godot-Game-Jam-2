@tool
class_name WeaponTail
extends Node2D

var enable: bool = false:
	set(new):
		enable = new
		visible  = new


@export var width: int = 10:
	set(new):
		width = new
		%Line2D.width = new

var point_arr:PackedVector2Array = []

func _ready() -> void:
	enable = false
	point_arr.resize(10)

const MAX_DIST = 5.0
const POINT_MOVE_SPEED = 20.0

func _process(delta: float) -> void:
	%Line2D.global_position = Vector2.ZERO
	%Line2D.global_rotation = 0.0
	%Line2D.global_scale = Vector2.ONE
	%Line2D.top_level = true

	var target = global_position
	point_arr[0] = target
	_distance_constraint()
	_point_move(delta)
	%Line2D.points = point_arr
	
func _distance_constraint():
	var arr = point_arr
	var target := point_arr[0]
	for i in range(1, point_arr.size()):
		arr[i] = _clamp_lenght(arr[i] - arr[i-1]) + arr[i-1]

func _point_move(dt: float):
	var arr = point_arr
	for i in range(1, point_arr.size()):
		arr[i] += (arr[i-1] - arr[i]).normalized() * dt * POINT_MOVE_SPEED
	
func _clamp_lenght(vec: Vector2)-> Vector2:
	return vec.normalized() * clampf(vec.length(), 0.0, MAX_DIST)

class_name Move
extends Action

## 最大速度
@export var MAX_SPEED:Vector2 = Vector2(100, 270)

## 加速時間
## 在某些行動方式中不會使用此參數
@export var INCREASE := 7.0

## 減速時間
## 在某些行動方式中不會使用此參數
@export var DECREASE := 20.0 #0.17

## 社交距離
## 遠離玩家角色的距離
## 主要用於遠程角色的位置調整
@export var social_distance:Vector2

func _physics_process(delta: float) -> void:
	if not enable: return

	try_move(delta)
	
	#target.set_collision_layer_value(2, target.is_on_floor())
	
	target.move_and_slide()



func try_move(delta: float) -> void:
	pass

func try_move_x(value:float, delta:float) -> float:
	# 处理左右移动
	var vec = _get_move_vec()
	if vec.x != 0: 
		return lerp(value, MAX_SPEED.x * vec.x, INCREASE * delta)
	else: # 停止移动
		return lerp(value, 0.0, DECREASE * delta)

func try_move_y(value:float, delta:float) -> float:
	return value



var _player_manager: PlayerManager

func get_move_pos() -> Vector2:
	var move_pos = _player_manager.get_player_position()
	if social_distance != Vector2.ZERO:
		var distance:Vector2 = move_pos - target.position
		if distance != Vector2.ZERO:
			if distance.x > 0:
				move_pos.x -= social_distance.x
			elif distance.x < 0:
				move_pos.x += social_distance.x

			move_pos.y -= social_distance.y
	return move_pos

func _get_player_distance() -> Vector2:
	return _player_manager.get_player_position() - target.position

func _get_move_vec()-> Vector2:
	return (get_move_pos() - target.position).normalized()

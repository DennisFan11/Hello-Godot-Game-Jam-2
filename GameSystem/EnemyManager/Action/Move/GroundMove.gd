class_name GroundMove
extends Move


@export var MAX_SPEED := 100.0 # 330
@export var INCREASE := 7.0
@export var DECREASE := 20.0 #0.17

@export var GRAVITY := MAX_SPEED * 10.0
@export var JUMP_SPEED := GRAVITY * 0.27 # 0.25


func try_move(delta: float) -> void:
	var new_velocity = target.velocity
	
	# 施加重力
	new_velocity.y += GRAVITY * delta
			
	# 处理左右移动
	var vec = _get_move_vec()
	if vec.x != 0: 
		new_velocity.x = lerp(new_velocity.x, MAX_SPEED * vec.x, INCREASE * delta)
	else: # 停止移动
		new_velocity.x = lerp(new_velocity.x, 0.0, DECREASE * delta)
	
	# 处理跳跃
	if _need_jump() and _can_jump(): 
		new_velocity.y = -JUMP_SPEED
	
	target.velocity = new_velocity

	target.set_collision_layer_value(2, target.is_on_floor())
	
	target.move_and_slide()

var _player_manager: PlayerManager
func _get_move_vec()-> Vector2:
	return (_player_manager.get_player_position() - target.position).normalized()

func _need_jump()-> bool:
	var dict = Utility.raycast(
		target.global_position,
		target.global_position + Vector2(_get_move_vec().x * 15.0, 0.0)
	)
	if not dict:
		return false
	
	if (dict["collider"] as Node2D).is_in_group("Block"):
		return true
	#if (dict["collider"] as Node2D).is_in_group("Enemy"):
		#return true
	
	return false

func _can_jump()-> bool:
	for i: Node2D in %FloorDetectArea.get_overlapping_bodies():
		if i != self and \
		 (i.is_in_group("Enemy") or \
		 i.is_in_group("Block")):
			return true
	return false
#

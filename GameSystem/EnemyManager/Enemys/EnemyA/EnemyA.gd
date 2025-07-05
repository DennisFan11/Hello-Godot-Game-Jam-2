class_name EnemyA
extends CharacterBody2D


const MAX_SPEED := 100.0 # 330
const INCREASE := 7.0
const DECREASE := 20.0 #0.17

const GRAVITY := MAX_SPEED*10.0
const JUMP_SPEED := GRAVITY * 0.27 # 0.25


func _physics_process(delta: float) -> void:
	
	# 施加重力
	velocity.y += GRAVITY * delta
			
	# 处理左右移动
	var vec = _get_move_vec()
	if vec.x != 0: 
		velocity.x = lerp(velocity.x, MAX_SPEED * vec.x, INCREASE * delta)
	else: # 停止移动
		velocity.x = lerp(velocity.x, 0.0, DECREASE * delta)
	
	# 处理跳跃
	if _need_jump() and _can_jump(): 
		velocity.y = -JUMP_SPEED
	
	set_collision_layer_value(2,is_on_floor())
	
	move_and_slide()

var _player_manager: PlayerManager
func _get_move_vec()-> Vector2:
	return (_player_manager.get_player_position() - position).normalized()

func _need_jump()-> bool:
	var dict = Utility.raycast(
		global_position,
		global_position + Vector2(_get_move_vec().x * 15.0, 0.0)
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
		if i != self and\
		 (i.is_in_group("Enemy") or\
		 i.is_in_group("Block")):
			return true
	return false
#

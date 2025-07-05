class_name Player
extends CharacterBody2D




func _physics_process(delta: float) -> void:
	_state_behavior(delta)



# =========================== Player Move ==========================



const MAX_SPEED := 100.0 # 330
const INCREASE := 7.0
const DECREASE := 20.0 #0.17

const GRAVITY := MAX_SPEED*10.0
const JUMP_SPEED := GRAVITY * 0.27

enum {IDLE, ON_WALL}

var state:int

func _state_behavior(delta: float)-> void:
	match state:
		IDLE:
			# 施加重力
			velocity.y += GRAVITY * delta
			
			# 处理左右移动
			var vec = Input.get_vector("left", "right", "up", "down")
			if vec.x != 0: 
				velocity.x = lerp(velocity.x, MAX_SPEED * vec.x, INCREASE * delta)
			else: # 停止移动
				velocity.x = lerp(velocity.x, 0.0, DECREASE * delta)
			
			# 处理跳跃
			if Input.is_action_just_pressed("space") and is_on_floor(): 
				velocity.y = -JUMP_SPEED
			if not is_on_floor() and\
				velocity.y > 0.0 and\
				(_climb_R() or _climb_L()) and\
				Input.is_action_pressed("shift"):
				state = ON_WALL
		ON_WALL:
			# 牆壁吸附力
			velocity.x = (1.0 if _climb_R() else -1.0) * 50.0
			
			# 上下移動
			var vec = Input.get_vector("left", "right", "up", "down")
			if vec.y != 0: 
				velocity.y =  lerp(velocity.y, MAX_SPEED * vec.y, INCREASE * delta)
			else:
				velocity.y = lerp(velocity.y, 0.0, DECREASE * delta)
			
			# 離開牆壁
			if ( !_climb_R() and !_climb_L() ) or \
				!Input.is_action_pressed("shift"):
				state = IDLE
			
			# 蹬牆跳
			if Input.is_action_just_pressed("space"):
				velocity.x * -1 * MAX_SPEED * 50.0
				velocity.y = -JUMP_SPEED
				state = IDLE
			
	move_and_slide()


func _climb_R()-> bool:
	for i in %RightArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

func _climb_L()-> bool:
	for i in %LeftArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

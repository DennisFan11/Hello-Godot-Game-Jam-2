class_name FSM_Mouse extends Node2D

### NOTE 左鍵及右鍵 狀態機 覆寫方法來存取
enum {L_CLICK, L_CLICKING, L_FINISH, IDLE, R_CLICK, R_CLICKING, R_FINISH, }
enum {LEFT, RIGHT}

#--------------------------可覆寫區-------------------------
#func _L_click(): # exec-once
	#pass
#func _L_clicking():
	#pass
#func _L_finish(): #exec-once
	#pass

func _Idle(): # 未按下
	pass

func _R_click(): # exec-once
	pass
func _R_clicking():
	pass
func _R_finish(): #exec-once
	pass
#--------------------------內部實作---------------------------


#region 內部實作
var _state = IDLE
func _physics_process(delta: float) -> void:
	match _state:
		#L_CLICK: # 左鍵按下 (建造開始)
			#_state = L_CLICKING
			#_L_click()
		#L_CLICKING: # 左鍵持續下壓 ()
			#_L_clicking()
		#L_FINISH: # 左鍵彈起 (建造完成)
			#_state = IDLE
			#_L_finish()
			
		IDLE: # 左鍵未按下 (默認狀態)
			_Idle()
			
		R_CLICK:
			_state = R_CLICKING
			_R_click()
		R_CLICKING:
			_R_clicking()
		R_FINISH:
			_state = IDLE
			_R_finish()


func _unhandled_input(event):
	if event.is_action_pressed("left_click"):
		_state = L_CLICK
	elif event.is_action_released("left_click"):
		_state = L_FINISH
	elif event.is_action_pressed("right_click"):
		_state = R_CLICK
	elif event.is_action_released("right_click"):
		_state = R_FINISH
#endregion

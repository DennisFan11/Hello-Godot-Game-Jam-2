class_name Action
extends Node

## 啟用行動, 此功能主要為boss的切換階段設計
@export var enable:bool = true:
	set = set_enable
## 固定啟用狀態
@export var fixed_enable_state:bool = false

## 冷卻時間
@export var cooldown: float = 0.33

@export_group("主目標")
## 主目標
@export var target: Node2D:
	set = set_target
## 若已有主目標, 使主目標無法更改
@export var fixed_target:bool = false

@export_group("操作目標")
## 操作目標 [br]
## 對部份需要分開行動和狀態的方式增加第二目標選擇
@export var control_target: Node2D:
	set = set_control
## 若已有操作目標, 使操作目標無法更改
@export var fixed_control:bool = false

var _cooldown_timer := CooldownTimer.new()



func set_enable(value:bool):
	if not fixed_enable_state \
	and enable != value:
		enable = value
		return true
	return false

func switch_enable():
	set_enable(not enable)



func set_target(t: Node2D) -> bool:
	if not fixed_target or not target:
		target = t
		set_control(t)
		return true
	return false

func set_control(t) -> bool:
	if not fixed_control or not control_target:
		control_target = t
		return true
	return false

func set_target_anim_state(key, value):
	if target.has_method("set_anim_state"):
		target.set_anim_state(key, value)

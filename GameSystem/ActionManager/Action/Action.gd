class_name Action
extends Node

## 啟用行動, 此功能主要為boss的切換階段設計
@export var enable:bool = true:
	set = set_enable
## 固定啟用狀態
@export var fixed_enable_state:bool = false

## 冷卻時間
@export var cooldown: float = 0.33


@export_group("操作目標")
## 操作目標
## 所有行動將以此目標為主
@export var target: Node2D:
	set = set_target
## 若已有主目標, 使主目標無法更改
@export var fixed_target:bool = false

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
		return true
	return false

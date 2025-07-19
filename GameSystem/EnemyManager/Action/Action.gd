class_name Action
extends Node

## 啟用行動, 此功能主要為boss的切換階段設計
@export var enable:bool = true
## 冷卻時間
@export var cooldown: float = 0.33

## 控制目標
var target: CharacterBody2D

var _cooldown_timer := CooldownTimer.new()

func set_target(t: CharacterBody2D):
	target = t

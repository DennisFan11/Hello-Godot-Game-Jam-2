class_name ActionManager
extends Node

@export var target: CharacterBody2D

func set_target(t: CharacterBody2D):
	target = t
	for children in get_children():
		if children is Action:
			children.set_target(t)

func _ready() -> void:
	if not target:
		var parent = get_parent()
		if parent is Enemy:
			set_target(get_parent())

## 加入更換行動的方法

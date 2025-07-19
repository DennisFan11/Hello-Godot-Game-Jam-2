class_name ActionManager
extends Node

@export var target: Node2D

func set_children_target(t:Node2D = target):
	for children in get_children():
		if children is Action:
			children.set_target(t)

func _ready() -> void:
	if not target:
		target = get_parent()
	set_children_target()

## 加入更換行動的方法

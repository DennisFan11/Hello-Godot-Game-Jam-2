class_name ActionManager
extends Node

@export var target: CharacterBody2D

func set_children_target(t:CharacterBody2D = target):
	for children in get_children():
		if children is Action:
			children.set_target(t)

func _ready() -> void:
	if not target:
		var parent = get_parent()
		if parent is CharacterBody2D:
			target = parent
	set_children_target()

## 加入更換行動的方法

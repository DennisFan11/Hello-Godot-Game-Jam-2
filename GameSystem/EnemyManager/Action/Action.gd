class_name Action
extends Node

@export var target: CharacterBody2D

func set_target(t: CharacterBody2D):
	target = t

func _ready() -> void:
	if not target:
		target = get_parent()

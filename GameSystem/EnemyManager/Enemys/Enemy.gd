class_name Enemy
extends CharacterBody2D

@export var _hp: float = 30

@export var move:Action
@export var attack:Action


func damage(dmg: float):
	_hp -= dmg
	if _hp < 0.0: _dead()

func push(vec: Vector2):
	pass

func _dead():
	queue_free()

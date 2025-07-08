class_name WeaponManager
extends Node2D

func _ready() -> void:
	DI.register("_weapon_manager", self)

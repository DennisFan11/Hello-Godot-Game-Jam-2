class_name WeaponEditor
extends Node2D

func _ready() -> void:
	DI.register("_weapon_editor", self)

var _shader_manager: ShaderManager
func start_event():
	_shader_manager.enable("frosted_glass")
	visible = true
	
	
	await _finished
	visible = false
	_shader_manager.disable("frosted_glass")
signal _finished

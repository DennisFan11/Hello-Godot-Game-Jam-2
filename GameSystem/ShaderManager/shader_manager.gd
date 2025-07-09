class_name ShaderManager
extends Node2D

func _ready() -> void:
	DI.register("_shader_manager", self)

func _process(delta: float) -> void:
	position = get_viewport().get_camera_2d().position


@onready var _shader_map = {
	"frosted_glass": %FrostedGlass
}

func enable(shader_name: String):
	_shader_map[shader_name].visible = true
	
func disable(shader_name: String):
	_shader_map[shader_name].visible = false

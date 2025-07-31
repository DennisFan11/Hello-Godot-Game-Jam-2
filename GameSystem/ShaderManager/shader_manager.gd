class_name ShaderManager
extends Node2D

func _ready() -> void:
	DI.register("_shader_manager", self)

func _process(delta: float) -> void:
	position = get_viewport().get_camera_2d().position


func set_shader_visible(shader_name:String, value:bool):
	var shader = get_node_or_null(shader_name)
	if shader:
		shader.visible = value

func enable(shader_name: String):
	set_shader_visible(shader_name, true)

func disable(shader_name: String):
	set_shader_visible(shader_name, false)

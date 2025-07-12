class_name MessageBoxManager
extends Node2D


func _ready() -> void:
	DI.register("_message_box_manager", self)


var SCENE = preload("uid://dsa70x1ovq67v")

func create_message_box()-> MessageBox:
	var node: MessageBox = SCENE.instantiate()
	add_child(node)
	return node

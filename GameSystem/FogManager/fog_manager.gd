class_name FogManager
extends IGameSubManager



const EDGE = 100000.0


func _ready() -> void:
	DI.register("_fog_manager", self)
	
	%Polygon2D.polygon = [
		Vector2(-EDGE, -EDGE),
		Vector2(EDGE, -EDGE),
		Vector2(EDGE, EDGE),
		Vector2(-EDGE, EDGE),
	]


func create_light()-> Light:
	var node = preload("uid://dpvxk3l0mjfpx").instantiate()
	%LightNodes.add_child(node)
	return node

func create_line_light()-> LineLight:
	var node = preload("uid://ch86uotetkbml").instantiate()
	%LightNodes.add_child(node)
	return node

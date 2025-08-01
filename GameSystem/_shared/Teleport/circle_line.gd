@tool
extends Line2D
func _ready() -> void:
	pass



@export var CIRCLE_R: float:
	set(new):
		CIRCLE_R = new
		reset_circle()
		

func reset_circle():
	points = GeometryShapeTool.gen_circle(CIRCLE_R, Vector2.ZERO)

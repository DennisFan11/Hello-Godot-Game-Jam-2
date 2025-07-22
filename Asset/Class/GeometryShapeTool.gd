class_name GeometryShapeTool
extends Node



static func gen_circle(radius: float, offset: Vector2, POINT_SIZE:int = 18)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in range(POINT_SIZE):
		var angle:float = (float(i)/POINT_SIZE) * 2.0*PI
		arr.append(offset + radius * Vector2(cos(angle),  sin(angle)) )
	return arr

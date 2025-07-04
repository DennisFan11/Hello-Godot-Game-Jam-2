class_name Triangle extends Polygon2D


##上下反轉
var flip:bool = false

## 外接圓半徑
var r:float = 10 

func set_edge(edge: float)-> void:
	r = edge / (sqrt(3))

func update_points():
	var arr = []
	for i in range(3):
		var angle = PI*2.0/3.0*i + PI/2.0 + (PI if flip else 0.0)
		arr.append(Vector2(cos(angle), sin(angle)) * r)
		polygon = arr
		%Line2D.points = arr

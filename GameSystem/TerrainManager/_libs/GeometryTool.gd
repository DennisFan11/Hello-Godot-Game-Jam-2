class_name GeometryTool
extends Node2D
### INFO ### 主要提供3種功能
### VertexOptimization
### Merge_hole_polygon
### Calculate_polygon_area

## 使用 block 座標
static func get_block_bounding_box(global_polygon: PackedVector2Array, block_size: Vector2)-> Array:
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for point in global_polygon:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)

	var start := Vector2(floor(min_x / block_size.x), floor(min_y / block_size.y)) - Vector2.ONE
	var end := Vector2(ceil(max_x / block_size.x), ceil(max_y / block_size.y)) + Vector2.ONE
	return [start, end]


static func _sort_points(array:Array)->PackedVector2Array: # 計算順時針多邊形
	"""
	// 輸入: 2點座標 (全域座標)
	輸出: 順時針多邊形 points
	"""
	var cp = Vector2.ZERO
	for i in array:
		cp+=i
	cp/=array.size()
	var center_angle_sort = func(A:Vector2,B:Vector2) -> bool: # 中心最大角度排序 lambda (順時鐘)
		if (A-cp).angle()>=(B-cp).angle():
			return false
		return true
	array.sort_custom(center_angle_sort)# (順時鐘排序)
	return PackedVector2Array(array)

static func _merge_nearby_cut_edges(polygon_points: PackedVector2Array, cut_edges: PackedVector2Array, merge_distance: float) -> PackedVector2Array:
	var merged_cut_edges = PackedVector2Array()
	
	# 遍历多边形顶点，进行合并处理
	for i in range(polygon_points.size()):
		var current_point = polygon_points[i]
		
		# 检查当前顶点是否在裁剪边界中
		if cut_edges.has(current_point):
			# 对裁剪边界顶点进行合并
			if merged_cut_edges.size() > 0 and merged_cut_edges[merged_cut_edges.size() - 1].distance_to(current_point) <= merge_distance:
				continue  # 如果当前顶点距离上一个合并的顶点在阈值内，则跳过
		merged_cut_edges.append(current_point)
	
	# 如果需要保持多边形闭合性，可以在这里添加处理逻辑
	# 注意：如果裁剪边界顶点形成闭合轮廓，可以检查并处理首尾顶点的距离
	
	return merged_cut_edges

static func _smooth_cut_edges(polygon_points: PackedVector2Array, cut_edges: PackedVector2Array, iterations: int) -> PackedVector2Array:
	var smoothed_points = polygon_points.duplicate()

	for inter in range(iterations):
		var new_points = smoothed_points.duplicate()

		for i in range(smoothed_points.size()):
			var current_point = smoothed_points[i]

			# 仅对裁剪边界顶点进行平滑
			if cut_edges.has(current_point):
				var prev_index = (i - 1 + smoothed_points.size()) % smoothed_points.size()
				var next_index = (i + 1) % smoothed_points.size()
				
				var prev_point = smoothed_points[prev_index]
				var next_point = smoothed_points[next_index]
				
				# 平滑处理
				new_points[i] = (prev_point + next_point) / 2.0
		smoothed_points = new_points
	return smoothed_points

static func _reduce_polygon_vertices(polygon_points: PackedVector2Array, cut_edges: PackedVector2Array, angle_threshold: float) -> PackedVector2Array:
	var reduced_points = PackedVector2Array()
	var count = polygon_points.size()
	
	for i in range(count):
		var prev_index = (i - 1 + count) % count
		var next_index = (i + 1) % count
		
		var prev_point = polygon_points[prev_index]
		var current_point = polygon_points[i]
		var next_point = polygon_points[next_index]
		
		var v1 = (prev_point - current_point).normalized()
		var v2 = (next_point - current_point).normalized()
		
		var angle = v1.angle_to(v2)
		
		# 只有当角度大于指定阈值时，才保留当前顶点
		if abs(angle) > deg_to_rad(angle_threshold) or !current_point in cut_edges:
			reduced_points.append(current_point)
	
	return reduced_points

static func _get_cut_indices(new:PackedVector2Array, old:PackedVector2Array): # 不包含頭尾的斷面
	var cut_indices = []
	for i in range(new.size()):
		if i == new.size()-1:
			if !old.has(new[i-1]) and !old.has(new[i]) and !old.has(new[0]):
				cut_indices.append(new[i])
				continue
			continue
		if !old.has(new[i-1]) and !old.has(new[i]) and !old.has(new[i+1]):
			cut_indices.append(new[i])
	return cut_indices

static func _calculate_polygon_area(polygon_points: PackedVector2Array) -> float: # 多邊形面積計算
	var area := 0.0
	var n := polygon_points.size()
	for i in range(n):
		var j := (i + 1) % n
		area += polygon_points[i].x * polygon_points[j].y
		area -= polygon_points[j].x * polygon_points[i].y
	area = abs(area) / 2.0
	return area

static func Calculate_polygon_area(origin: PackedVector2Array, local_polygon: PackedVector2Array)->float:
	var area:float = 0.0
	var inter_polygons: Array[PackedVector2Array] = Geometry2D.intersect_polygons(origin, local_polygon)
	for i: PackedVector2Array in inter_polygons:
		area += _calculate_polygon_area( i )
	return area

static func VertexOptimization(polygon_points: PackedVector2Array, origin:PackedVector2Array, BlockSize:Vector2):
	if polygon_points.size()<= 10:
		return polygon_points
	const merge_distance = 10.0 # 10 一格 25
	const iterations = 1 #20 3 
	const angle_threshold = 15.0 # 10
	var cut_edges = _get_cut_indices(polygon_points, origin)
	
	polygon_points = _smooth_cut_edges(polygon_points, cut_edges, iterations)
	
	#TEST 由切割面改為非方塊邊緣
	var BLOCK_SIZE = BlockSize.x
	var arr = []
	for i:Vector2 in polygon_points:
		if (fmod(i.x, BLOCK_SIZE) > 10) and (fmod(i.y, BLOCK_SIZE) > 10):
			arr.append(i)
	#cut_edges = arr
	cut_edges += arr
	
	
	polygon_points = _merge_nearby_cut_edges(polygon_points, cut_edges, merge_distance)
	polygon_points = _reduce_polygon_vertices(polygon_points, cut_edges, angle_threshold)
	return polygon_points

static func _connect_hole_with_algorithm(outer_polygon: PackedVector2Array, hole_polygon: PackedVector2Array) -> PackedVector2Array:
	var combined_polygon = PackedVector2Array()
	var find_shortest_connection = func(outer_polygon: PackedVector2Array, hole_polygon: PackedVector2Array):
		var min_distance = INF
		var best_outer_index = -1
		var best_hole_index = -1

		for i in range(outer_polygon.size()):
			for j in range(hole_polygon.size()):
				var distance = outer_polygon[i].distance_to(hole_polygon[j])
				if distance < min_distance:
					min_distance = distance
					best_outer_index = i
					best_hole_index = j

		return [best_outer_index, best_hole_index]
	
	# 确保外多边形闭合
	if outer_polygon[0] != outer_polygon[-1]:
		outer_polygon.append(outer_polygon[0])
	
	# 找到最佳连接点
	var connet = find_shortest_connection.call(outer_polygon, hole_polygon)
	var outer_index = connet[0]
	var hole_index = connet[1]
	
	# 添加外多边形的顶点，直到连接点
	for i in range(outer_index + 1):
		combined_polygon.append(outer_polygon[i])
	
	# 添加连接缝隙
	var offset = Vector2.ONE*0.1
	combined_polygon.append(hole_polygon[hole_index])
	combined_polygon.append(outer_polygon[outer_index])
	
	# 添加孔的顶点，绕一圈再回到 hole_index
	for j in range(hole_index, hole_polygon.size()):
		combined_polygon.append(hole_polygon[j])
	for j in range(hole_index + 1):
		combined_polygon.append(hole_polygon[j])
		if j == hole_index:
			combined_polygon[-1]+= (combined_polygon[-2]-combined_polygon[-1]).normalized()*offset
		
	# 完成外多边形剩余部分
	for i in range(outer_index, outer_polygon.size()):
		combined_polygon.append(outer_polygon[i])
		if i == outer_index+1:
			combined_polygon[-2]+= (combined_polygon[-1]-combined_polygon[-2]).normalized()*offset
	#combined_polygon.reverse()
	return combined_polygon

static func Merge_hole_polygon(polygons: Array[PackedVector2Array])-> Array[PackedVector2Array]:
	var arr: Array[PackedVector2Array] = []
	for i in range(polygons.size()):
		if Geometry2D.is_polygon_clockwise(polygons[i]) and i!= 0 :
			arr[i-1] = _connect_hole_with_algorithm(arr[i-1], polygons[i])
			continue
		arr.append(polygons[i])
	return arr

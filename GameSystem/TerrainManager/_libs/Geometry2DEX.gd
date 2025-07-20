class_name Geometry2DEX extends Node


# 平滑处理函数：利用二次贝塞尔曲线平滑多边形
static func smooth(polygon: PackedVector2Array, resolution: int = 60) -> PackedVector2Array:
	# 若多边形点数不足，直接返回原始数据
	if polygon.size() < 2:
		return polygon

	var smoothed = PackedVector2Array()
	# 判断多边形是否闭合（首尾点相同）
	var is_closed = polygon[0] == polygon[polygon.size() - 1]

	if is_closed:
		# 对闭合多边形进行平滑处理
		# 注意：通常闭合多边形最后一个点是重复首点，所以只处理到倒数第二个点
		for i in range(polygon.size() - 1):
			# 计算前后点索引（注意闭合性）
			var p_prev = polygon[(i - 1 + polygon.size() - 1) % (polygon.size() - 1)]
			var p_curr = polygon[i]
			var p_next = polygon[(i + 1) % (polygon.size() - 1)]
			# 定义贝塞尔曲线的起点与终点为相邻两点的中点
			var start = (p_prev + p_curr) * 0.5
			var end = (p_curr + p_next) * 0.5
			# 在 [0, 1) 之间采样 resolution 个点（t=0 时的点已在前一个段中采样过）
			for j in range(resolution):
				var t = j / float(resolution)
				var pt = quadratic_bezier(start, p_curr, end, t)
				smoothed.append(pt)
		# 将曲线闭合，添加首个采样点
		smoothed.append(smoothed[0])
	else:
		# 对开放多边形进行平滑处理
		# 首先保留第一个点
		smoothed.append(polygon[0])
		# 对中间部分，每个顶点作为控制点进行二次贝塞尔曲线插值
		for i in range(1, polygon.size() - 1):
			var p_prev = polygon[i - 1]
			var p_curr = polygon[i]
			var p_next = polygon[i + 1]
			# 定义曲线段的起点和终点分别为当前顶点与前后顶点的中点
			var start = (p_prev + p_curr) * 0.5
			var end = (p_curr + p_next) * 0.5
			# 对每个曲线段在 t ∈ [0, 1] 内采样（跳过 t=0，避免重复添加）
			for j in range(1, resolution + 1):
				var t = j / float(resolution)
				var pt = quadratic_bezier(start, p_curr, end, t)
				smoothed.append(pt)
		# 最后保留最后一个点
		smoothed.append(polygon[polygon.size() - 1])
	return smoothed

# 辅助函数：计算二次贝塞尔曲线上的插值点
static func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2

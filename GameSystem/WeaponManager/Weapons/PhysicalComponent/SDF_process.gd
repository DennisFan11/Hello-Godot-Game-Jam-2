class_name SDF_process
extends Node


static func img2SDF(image: Image)-> Image:
	var _img := Image.new()
	_img.copy_from(image)
	return distance_border(
		expand_img(_img, _img.get_size() * 2.0),
		10)
	
static func expand_img(image: Image, size: Vector2) -> Image:
	var original_size := image.get_size()
	var new_width := int(size.x)
	var new_height := int(size.y)

	# 建立新圖像，RGBA 格式，背景為透明
	var new_image := Image.create(new_width, new_height, false, image.get_format())
	new_image.fill(Color(0, 0, 0, 0))

	# 計算置中偏移
	var offset := Vector2(
		floor((new_width - original_size.x) / 2.0),
		floor((new_height - original_size.y) / 2.0)
	)

	# 拷貝原始影像進新的影像
	new_image.blit_rect(
		image,
		Rect2(Vector2.ZERO, original_size),
		offset
	)

	return new_image

static func distance_border(image, width):
	var size = image.get_size()
	var result = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)

	var distance = {}
	var visited = {}

	var heap = MinHeap.new()

	# 初始化：所有非透明像素設為距離 0，加入 heap
	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2i(x, y)
			var color = image.get_pixelv(pos)
			if color.a > 0.0:
				distance[pos] = 0.0
				heap.push(pos, 0.0)
			else:
				distance[pos] = INF

	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1),
		Vector2i(1, -1), Vector2i(-1, 1)
	]

	# Dijkstra 擴散：距離最小者先擴散
	while not heap.is_empty():
		var current = heap.pop()
		if visited.has(current):
			continue
		visited[current] = true

		var curr_dist = distance[current]
		if curr_dist > float(width):
			continue

		for offset in directions:
			var neighbor = current + offset
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= size.x or neighbor.y >= size.y:
				continue
			var step = offset.length()
			var new_dist = curr_dist + step
			if new_dist < distance[neighbor]:
				distance[neighbor] = new_dist
				heap.push(neighbor, new_dist)

	# 計算 alpha 值，產出結果圖
	for y in range(size.y):
		for x in range(size.x):
			var pos = Vector2i(x, y)
			var dist = distance.get(pos, width + 1.0)
			var alpha = 0.0
			if dist <= float(width):
				alpha = 1.0 - (dist / float(width))
			if image.get_pixelv(pos).a > 0.0:
				alpha = 1.0
			result.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	return result

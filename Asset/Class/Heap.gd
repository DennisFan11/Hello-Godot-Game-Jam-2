extends RefCounted
class_name MinHeap

var _heap = []

func size():
	return _heap.size()

func is_empty():
	return _heap.is_empty()

func push(value, priority):
	_heap.append({ "value": value, "priority": priority })
	_sift_up(_heap.size() - 1)

func pop():
	if _heap.is_empty():
		return Vector2i()
	var root = _heap[0]["value"]
	var last = _heap.pop_back()
	if not _heap.is_empty():
		_heap[0] = last
		_sift_down(0)
	return root

func _sift_up(index):
	while index > 0:
		var parent = (index - 1) / 2
		if _heap[index]["priority"] < _heap[parent]["priority"]:
			_swap(index, parent)
			index = parent
		else:
			break

func _sift_down(index):
	var size = _heap.size()
	while true:
		var left = index * 2 + 1
		var right = index * 2 + 2
		var smallest = index

		if left < size and _heap[left]["priority"] < _heap[smallest]["priority"]:
			smallest = left
		if right < size and _heap[right]["priority"] < _heap[smallest]["priority"]:
			smallest = right

		if smallest == index:
			break
		_swap(index, smallest)
		index = smallest

func _swap(i, j):
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp

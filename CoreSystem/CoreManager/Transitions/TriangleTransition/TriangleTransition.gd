extends ITransition


func _ready() -> void:
	_in()
	_set_timer()



const TIME = 1.5
func _in():
	_spawn_triangle()
	var tween = get_tree().create_tween()
	tween.tween_method(_reset_triangle, 0.0, 1.0, TIME)
	tween.tween_callback( func():in_end.emit() )
	_visible = true

func _out():
	var tween = get_tree().create_tween()
	tween.tween_method(_reset_triangle, 1.0, 0.0, TIME)
	tween.tween_callback( func():out_end.emit() )
	tween.tween_callback( _clear_triangle )
	tween.tween_callback( queue_free )
	_visible = false

var _visible = false
const EDGE := 80.0
var W := EDGE/2.0
var H := _get_triangle_height(EDGE)
var _triangle_arr = []
var arr_lock = Mutex.new()

func _spawn_triangle()-> bool:
	if not arr_lock.try_lock():
		return false
	
	# free all triangle
	_clear_triangle()
	
	var size: Vector2 = \
	Vector2(_get_viewport_size()) / Vector2(W, H) + Vector2.ONE * 3
	for y in range(size.y):
		_triangle_arr.append([])
		for x in range(size.x):
			var triangle:Triangle = preload("uid://4m4ofmhh0g84").instantiate()
			%CanvasLayer.add_child(triangle)
			_triangle_arr[-1].append(triangle)
			triangle.position = Vector2(x*W, y*H)
			triangle.r = _get_triangle_R(EDGE)
			triangle.scale = Vector2.ONE if _visible else Vector2.ZERO
			if x%2!=0:
				triangle.flip = true
				triangle.position.y += H-_get_triangle_R(EDGE)
			if y%2!=0:
				triangle.position.x -= EDGE/2.0
			triangle.update_points()
	#print("triangle count:",_triangle_arr.size() * _triangle_arr[0].size())

	arr_lock.unlock()
	return true

func _clear_triangle():
	for i in _triangle_arr:
		for j in i: j.queue_free()
	_triangle_arr.clear()

@export var anime_map:SampleableGradientTexture2D
func _reset_triangle(progress: float)-> void:
	#var start_time = Time.get_ticks_usec()
	
	if not arr_lock.try_lock():
		return
	const TRANSITION_AREA = 1.0 # 值越大, 過度區越小
	for y in range(_triangle_arr.size()):
		for x in range(_triangle_arr[y].size()):
			if anime_map:
				var uv = Vector2(x, y)/Vector2(_triangle_arr[y].size(), _triangle_arr.size())
				var r = anime_map.samp_with_uv(uv).r - 1.0
				var fix_progress = ((r + progress*2) * TRANSITION_AREA)
				
				fix_progress = clampf(fix_progress, 0.0, 1.0)
				_triangle_arr[y][x].scale = Vector2.ONE *  fix_progress
			else: # defult
				_triangle_arr[y][x].scale = Vector2.ONE * progress
	
	arr_lock.unlock()
	
	#print("執行時間（微秒）: ", Time.get_ticks_usec() - start_time)


func _get_triangle_height(edge: float) -> float:
	return sqrt(3) / 2 * edge
func _get_triangle_R(edge: float)-> float:
	return edge / (sqrt(3))


var timer:Timer
func _set_timer(): # ON_READY
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.1
	add_child(timer)
	timer.timeout.connect(_on_timeout)
	get_viewport().size_changed.connect(timer.start)

func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		timer.start()

func _get_viewport_size():
	return Vector2(1728, 972)
	return get_viewport().size

func _on_timeout():
	pass
	#while not _spawn_triangle():
		#await get_tree().create_timer(0.1).timeout






#

class_name CameraManager
extends Camera2D


func _ready() -> void:
	DI.register("_camera_manager", self)
	%AudioListener2D.make_current()
	zoom = Vector2.ONE * 4.0

var _player_manager: PlayerManager

const SPEED:float = 5 # lerp time

var target := Vector2.ZERO
func _process(delta: float) -> void:
	if not _player_manager: return
	if not _player_manager.player: return
	
	target = _player_manager.player.position
	if target:
		position = position.lerp(target, SPEED*delta)
		
	rotation = lerp_angle(
		rotation, _player_manager.get_player_rotation()*0.1, SPEED*delta
	)

func zoom_out(time: float):
	var tween : = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2.ONE *2.0, ZOOM_SPEED)
	
	await get_tree().create_timer(time).timeout
	tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2.ONE *4.0, ZOOM_SPEED)
	
	

const ZOOM_SPEED:float = 1.2 
const ZOOM_TIME:float = 0.08 #0.05
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("scroll_down"):
		##%Camera2D.zoom *= 0.9
		#var tween := get_tree().create_tween()
		#tween.tween_property(self,"zoom",zoom / ZOOM_SPEED,ZOOM_TIME)
	#elif event.is_action_pressed("scroll_up"):
		##%Camera2D.zoom *= 1.1
		#var tween := get_tree().create_tween()
		#tween.tween_property(self,"zoom",zoom * ZOOM_SPEED,ZOOM_TIME)
	#if event is InputEventPanGesture:
		#zoom -= Vector2.ONE * 2.0 * (event.delta.y * get_process_delta_time())

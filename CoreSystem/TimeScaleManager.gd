## TimeScaleManager.gd
extends Node



const TWEEN_TIME = 0.1

func slow_down(target_scale: float, time: float):
	set_scale(target_scale)
	await get_tree().create_timer(time, true, false, true).timeout
	set_scale(1.0)



func set_scale(new_scale: float):
	var tween := get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", new_scale, TWEEN_TIME)

func get_scale()-> float:
	return Engine.time_scale

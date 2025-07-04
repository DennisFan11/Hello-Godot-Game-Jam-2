# cooldown_timer.gd
class_name CooldownTimer
extends RefCounted

var _next_time := 0.0

func get_ticks_sec() -> float:
	return Time.get_ticks_msec()/1000.0

func is_ready() -> bool:
	return get_ticks_sec() >= _next_time

func trigger(cd: float) -> void:
	_next_time = get_ticks_sec() + cd

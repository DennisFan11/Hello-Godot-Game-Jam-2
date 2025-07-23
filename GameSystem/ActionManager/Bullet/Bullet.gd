class_name Bullet
extends Derivative

@export var cooldown: float = 1

var _cooldown_timer := CooldownTimer.new()

func _ready() -> void:
	_cooldown_timer.trigger(cooldown)

func _physics_process(delta: float) -> void:
	if _cooldown_timer.is_ready():
		queue_free()

class_name Attack
extends Action

@export var damage: float = 1.0

var _cooldown_timer := CooldownTimer.new()

func _physics_process(delta: float) -> void:
	try_attack(delta)
	
func try_attack(delta):
	pass

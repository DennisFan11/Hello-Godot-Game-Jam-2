class_name Attack
extends Action

## 攻擊力
@export var damage: float = 1.0

func _physics_process(delta: float) -> void:
	if enable and _cooldown_timer.is_ready():
		try_attack(delta)
	
func try_attack(delta):
	pass

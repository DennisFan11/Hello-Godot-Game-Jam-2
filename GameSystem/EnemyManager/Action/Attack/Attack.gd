class_name Attack
extends Action

## 攻擊力
@export var damage: float = 1.0

func _physics_process(delta: float) -> void:
	if enable and _cooldown_timer.is_ready():
		try_attack(delta)
	
func try_attack(delta):
	pass

func attack(player):
	player.take_damage(damage)

	if cooldown > 0.0:
		_cooldown_timer.trigger(cooldown)
	elif cooldown < 0.0: # 當<0時將在擊中後刪除, 主要用於投射物(箭)
		target.queue_free()

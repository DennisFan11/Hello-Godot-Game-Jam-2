class_name DispellingAttack
extends TouchAttack

func _ready() -> void:
	attack_type = "Bullet"

func attack(t):
	t.queue_free()

func update_attack_type():
	pass

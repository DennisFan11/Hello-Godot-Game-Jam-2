class_name DispellingAttack
extends TouchAttack

func _ready() -> void:
	attack_type = "Bullet"

func attack(t):
	printt("aaa", t is Bullet, t, Time.get_ticks_msec())
	t.queue_free()

func update_attack_type():
	pass

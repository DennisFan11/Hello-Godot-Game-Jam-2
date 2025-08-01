class_name Item
extends CharacterBody2D



func use_item(char:Player):
	var attack_manager:AttackManager = %AttackManager
	attack_manager.target = char
	attack_manager.set_children_target()
	attack_manager.enable_action()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		use_item(body)

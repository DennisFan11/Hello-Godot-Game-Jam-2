class_name Interacter
extends Area2D

var _interactable_areas: Array[Interactable] = []
func _on_area_entered(area: Area2D) -> void:
	if area is Interactable:
		area.enable()
		_interactable_areas.append(area)


func _on_area_exited(area: Area2D) -> void:
	if area is Interactable:
		area.disable()
		_interactable_areas.erase(area)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("F"):
		_interact()

func _interact():
	if _interactable_areas.is_empty():
		return 
	
	var player_pos: Vector2 = global_position
	var min_area: Interactable = Utility.min_custom(
			_interactable_areas,
			(func (A: Interactable, B: Interactable):
			return A.global_position.distance_to(player_pos) <\
			 B.global_position.distance_to(player_pos))
		)
	min_area.interact()

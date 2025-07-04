class_name TweenPanel
extends Panel



func _ready() -> void:
	await get_tree().process_frame
	scale = Vector2.ZERO
	pivot_offset = size/2.0

const TIME = 0.3

func _open()-> void:
	pivot_offset = size/2.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, TIME)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

func _close()-> Signal:
	pivot_offset = size/2.0
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, TIME)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	return get_tree().create_timer(TIME).timeout

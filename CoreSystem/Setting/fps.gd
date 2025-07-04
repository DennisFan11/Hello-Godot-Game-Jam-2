extends RichTextLabel
func _process(_delta: float) -> void:
	text = "[color=green][font_size=50]  Fps: {0}".format(
		[
			Performance.get_monitor(Performance.TIME_FPS)
		]
	)

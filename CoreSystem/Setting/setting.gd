extends Control

var open: bool = false:
	set(new):
		open = new
		if new:
			%Panel.visible = true
			%Panel._open()
			get_tree().current_scene.set_process_mode(PROCESS_MODE_DISABLED)
		else:
			await %Panel._close()
			%Panel.visible = false
			ConfigRepo.save()
			get_tree().current_scene.set_process_mode(PROCESS_MODE_INHERIT)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		open = !open


func _on_exit_button_pressed() -> void:
	open = false

func _on_setting_button_pressed() -> void:
	open = true

var _game_manager: GameManager
func _on_title_button_button_down() -> void:
	open = false
	DI.injection(self)
	if _game_manager:
		_game_manager.finish(false)
	else:
		CoreManager.goto_scene("Title")
	






func _ready() -> void:
	%BGMSlider.value = SoundManager.get_db(
		SoundManager.BUS.BGM
	)
	%BGMSlider.value_changed.connect(
		func(new): SoundManager.set_db(
			SoundManager.BUS.BGM, new)
	)
	
	
	%EffectSlider.value = SoundManager.get_db(
		SoundManager.BUS.EFFECT
	)
	%EffectSlider.value_changed.connect(
		func(new): SoundManager.set_db(
			SoundManager.BUS.EFFECT, new)
	)


func _on_clear_button_button_down() -> void:
	ConfigRepo.clear()

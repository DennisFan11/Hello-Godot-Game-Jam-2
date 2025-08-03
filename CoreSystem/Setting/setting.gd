extends Control

var open: bool = false:
	set(new):
		if new == open:
			return

		var game_manager = DI.get_dependence("_game_manager")
		if new:
			# 檢查是否正在運行, 如果不是則為其他界面, 取消開啟
			if game_manager:
				if not game_manager.can_process():
					return
			%Panel.visible = true
			%Panel._open()
			if game_manager:
				game_manager.set_process_mode(PROCESS_MODE_DISABLED)
		else:
			# 檢查是否正在運行, 如果是則為其他界面, 取消開啟
			if game_manager.can_process():
				return
			await %Panel._close()
			%Panel.visible = false
			ConfigRepo.save()
			if game_manager:
				game_manager.set_process_mode(PROCESS_MODE_INHERIT)
		open = new


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

var _shader_manager: ShaderManager
func _on_shader_test_button_toggled(toggled_on: bool) -> void:
	DI.injection(self)
	if _shader_manager:
		if toggled_on:
			_shader_manager.enable("FrostedGlass")
		else:
			_shader_manager.disable("FrostedGlass")

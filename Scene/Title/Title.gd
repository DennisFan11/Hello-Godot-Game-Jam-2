extends CanvasLayer

func _ready() -> void:
	SoundManager.play_bgm("title_music")
	%AnimationPlayer.play("page_turn_multiple")

func _on_button_pressed() -> void:
	_disable_buttons()
	%AnimationPlayer.play("page_turn_single")
	await %AnimationPlayer.animation_finished
	LevelManager.start_game()


func _on_upgrade_shop_button_pressed() -> void:
	_disable_buttons()
	await CoreManager.goto_scene("UpgradeShop")


#func _on_credit_button_pressed() -> void:
	#_disable_buttons()
	#CoreManager.goto_scene("Endding")

func _disable_buttons() -> void:
	%StartButton.disabled = true
	%UpgradeShopButton.disabled = true
	%CreditButton.disabled = true

	
#var _rot: float = -0.116937
#var _time = 0.0
#func _process(delta: float) -> void:
	#_time += delta
	#%Discord.scale = Vector2.ONE * (1.0 + 0.05 + sin(_time * 8.0) * 0.05)
	#%Discord.rotation = _rot + sin(_time * 2.0) * 0.15
#

func _on_discord_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

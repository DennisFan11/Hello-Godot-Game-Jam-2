extends Node2D


func _ready() -> void:
	pass
	#SoundManager.play_bgm("menu")

func _on_button_pressed() -> void:
	await CoreManager.goto_scene("Level1")
	#CoreManager.enter_game()


func _on_upgrade_shop_button_pressed() -> void:
	print("前往強化商店...")
	await CoreManager.goto_scene("UpgradeShop")


func _on_credit_button_button_down() -> void:
	CoreManager.goto_scene("Endding")

	
var _rot: float = -0.116937
var _time = 0.0
func _process(delta: float) -> void:
	_time += delta
	%Discord.scale = Vector2.ONE * (1.0 + 0.05 + sin(_time * 8.0) * 0.05)
	%Discord.rotation = _rot + sin(_time * 2.0) * 0.15


func _on_discord_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

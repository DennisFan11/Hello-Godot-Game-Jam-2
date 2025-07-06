class_name GameManager extends Node

# 升級系統實例 (由 DI 系統注入)
var _player_upgrade_system: PlayerUpgradeSystem

#func _save():
	#for i:Node in get_children():
		#if i.has_method("_save"): await i._save()
#func _load():
	#for i:Node in get_children():
		#if i.has_method("_load"): await i._load()

func _game_start_recursive(parent: Node):
	for i: Node in parent.get_children():
		_game_start_recursive(i)
	if parent.has_method("_game_start"):
		await parent._game_start()


func _ready() -> void:
	print("GameManager 正在初始化...")
	
	# 註冊 GameManager 到 DI 系統
	DI.register("_game_manager", self)
	
	# 等待 DI 系統注入升級系統
	await get_tree().process_frame
	
	# 遞歸重新注入
	DI.injection(self, true)
	
	#SoundManager.play_bgm_stack("game_normal")
	#await _load()
	await get_tree().process_frame
	await _game_start_recursive(self)
	
	print("✓ GameManager 初始化完成")

func _on_injected():
	"""DI 注入完成後的回調"""
	if _player_upgrade_system != null:
		print("✓ 升級系統已成功注入到 GameManager")
	else:
		print("⚠ 升級系統注入失敗")

# 獲取升級系統的便捷方法
func get_upgrade_system() -> PlayerUpgradeSystem:
	"""獲取升級系統實例"""
	return _player_upgrade_system

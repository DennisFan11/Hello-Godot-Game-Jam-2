class_name GameManager extends Node

## 前往下一關所需的擊殺數
@export var next_level_kill_count:int = 10

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
	
	# 遞歸重新注入
	DI.injection(self, true)
	
	#SoundManager.play_bgm_stack("game_normal")
	#await _load()
	await get_tree().process_frame
	await _game_start_recursive(self)
	
	print("✓ GameManager 初始化完成")

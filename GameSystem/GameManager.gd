class_name GameManager extends Node

## 前往下一關所需的擊殺數
@export var next_level_kill_count:int = 10

func Save():
	await _recursive_call(self, "_save")
func Load():
	await _recursive_call(self, "_load")
func _game_start_recursive():
	await _recursive_call(self, "_game_start")

func _recursive_call(node: Node, method:String):
	if node.has_method(method):
		await node.call(method)
	for i:Node in node.get_children():
		await _recursive_call(i, method)



func _ready() -> void:
	print("GameManager 正在初始化...")
	
	# 註冊 GameManager 到 DI 系統
	DI.register("_game_manager", self)
	
	# 遞歸重新注入
	DI.injection(self, true)
	
	#SoundManager.play_bgm_stack("game_normal")
	await Load()
	await get_tree().process_frame
	await _game_start_recursive()
	
	print("✓ GameManager 初始化完成")
func _exit_tree() -> void:
	await Save()

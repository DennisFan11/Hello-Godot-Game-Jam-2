extends Node
# LevelManager - 關卡管理器 (AutoLoad)
# 管理關卡的順序和進度

signal level_completed(current_level: String, next_level: String)
signal sequence_completed()

## 關卡順序配置
## 可在編輯器中設定或通過代碼修改
var LEVEL_SEQUENCE: Array[String] = [
	"Level1",
	"Level2",
	"Level3"
]

## 每個關卡所需擊殺數
var KILLS_REQUIRED: Array[int] = [
	5, 10, 15
]

## 當前關卡索引
var _current_level_index: int = -1 # 初始化為 -1 表示遊戲還未開始

## 是否已經開始遊戲
var _game_started: bool = false

## 是否已經初始化
var _initialized: bool = false
var _enemy_manager: EnemyManager
# 當前 Enemy 死掉總數
var _current_enemy_dead_count: int = 0

func _ready() -> void:
	_initialized = true
	# 註冊到 DI 系統
	DI.register("_level_manager", self)
	
	# 監聽 CoreManager 的場景切換信號
	if CoreManager and CoreManager.has_signal("scene_changed"):
		CoreManager.scene_changed.connect(_on_scene_changed)
		print("✓ LevelManager 已連接到 CoreManager 的場景切換信號")
	else:
		print("⚠ LevelManager 無法連接到 CoreManager 信號")
	
	print("✓ LevelManager (AutoLoad) 已初始化")

func _on_scene_changed(scene_name: String):
	"""當 CoreManager 切換場景時觸發"""
	print("收到場景切換信號: ", scene_name)
	# 如果 scene_name = 'Level1' 執行 start_game()
	if scene_name == "Level1":
		start_game()
	on_scene_loaded()

func _on_injected():
	# 嘗試獲取 EnemyManager 並連接信號
	_connect_enemy_manager()

func _connect_enemy_manager():
	"""嘗試連接到 EnemyManager"""
	# 從 DI 系統獲取 EnemyManager
	# 檢查 DI._dependence是否有 _enemy_manager 這個 key
	if "_enemy_manager" in DI._dependence:
		var enemy_manager_obj = DI._dependence["_enemy_manager"]
		
		# 檢查對象是否有效且未被釋放
		if is_instance_valid(enemy_manager_obj):
			_enemy_manager = enemy_manager_obj as EnemyManager
		else:
			printerr("⚠ LevelManager 發現 EnemyManager 對象已被釋放")
			_enemy_manager = null
			return
	else:
		# 找不到的話就中斷
		printerr("⚠ LevelManager 無法找到 EnemyManager")
		return
	
	if _enemy_manager and is_instance_valid(_enemy_manager):
		# 如果之前有連接其他的 EnemyManager，先斷開
		if _enemy_manager.enemy_died.is_connected(_on_enemy_died):
			_enemy_manager.enemy_died.disconnect(_on_enemy_died)
		
		# 連接新的 EnemyManager
		_enemy_manager.enemy_died.connect(_on_enemy_died)
		print("✓ LevelManager 已連接到新的 EnemyManager")
	else:
		print("⚠ LevelManager 無法找到有效的 EnemyManager")

## 公開方法：讓其他系統通知場景已載入
func on_scene_loaded():
	"""當新場景載入時調用此方法"""
	# 重置敵人死亡計數
	_current_enemy_dead_count = 0
	# 重新連接 EnemyManager
	_connect_enemy_manager()

func _on_enemy_died(enemy: Enemy):
	_current_enemy_dead_count += 1
	print("敵人死亡: ", enemy, " (總數: ", _current_enemy_dead_count, ")")
	# 當敵人死亡時，檢查是否需要進行關卡更新
	if not _game_started:
		return
	# 檢查是否達到下一關的擊殺數
	if _current_level_index < 0 or _current_level_index >= KILLS_REQUIRED.size():
		printerr("無效的關卡索引: ", _current_level_index)
		return
	if _current_enemy_dead_count >= KILLS_REQUIRED[_current_level_index]:
		print("達到關卡擊殺數: ", _current_enemy_dead_count, "需要: ", KILLS_REQUIRED[_current_level_index])
		# 前進到下一關
		var next_level = advance_to_next_level()
		if CoreManager:
			await CoreManager.goto_scene(next_level)

## 獲取當前關卡
func get_current_level() -> String:
	if _current_level_index < 0:
		return "未開始" # 遊戲還未開始
	if _current_level_index >= LEVEL_SEQUENCE.size():
		return "Title" # 如果超出範圍，回到標題
	return LEVEL_SEQUENCE[_current_level_index]

## 獲取下一關
func get_next_level() -> String:
	if _current_level_index < 0:
		return LEVEL_SEQUENCE[0] if LEVEL_SEQUENCE.size() > 0 else "Title" # 如果還未開始，下一關是第一關
	var next_index = _current_level_index + 1
	if next_index >= LEVEL_SEQUENCE.size():
		return "Title" # 如果是最後一關，回到標題
	return LEVEL_SEQUENCE[next_index]

## 前進到下一關
func advance_to_next_level() -> String:
	var current = get_current_level()
	_current_level_index += 1
	
	# 如果超出序列範圍，重置進度
	if _current_level_index >= LEVEL_SEQUENCE.size():
		print("關卡序列完成！重置進度並回到標題")
		reset_progress()
		sequence_completed.emit()
		return "Title"
	
	var next = get_current_level()
	
	print("關卡進度: {0} -> {1} (索引: {2}/{3})".format([
		current,
		next,
		_current_level_index,
		LEVEL_SEQUENCE.size()
	]))
	
	level_completed.emit(current, next)
	
	return next

## 重置關卡進度（回到標題時調用）
func reset_progress():
	_current_level_index = -1 # 重置為未開始狀態
	_game_started = false
	InGameSaveSystem.clear()
	print("關卡進度已重置")

## 設定關卡順序
func set_level_sequence(new_sequence: Array[String]):
	LEVEL_SEQUENCE = new_sequence
	reset_progress()
	print("關卡順序已更新: ", LEVEL_SEQUENCE)

## 跳到指定關卡索引
func jump_to_level_index(index: int):
	if index >= 0 and index < LEVEL_SEQUENCE.size():
		_current_level_index = index
		print("跳轉到關卡索引: {0} ({1})".format([index, get_current_level()]))
	else:
		printerr("無效的關卡索引: {0}".format([index]))

## 獲取進度信息
func get_progress_info() -> Dictionary:
	var display_index = _current_level_index + 1 if _current_level_index >= 0 else 0
	return {
		"current_index": _current_level_index,
		"current_level": get_current_level(),
		"next_level": get_next_level(),
		"total_levels": LEVEL_SEQUENCE.size(),
		"progress_percentage": float(display_index) / float(LEVEL_SEQUENCE.size()) * 100.0,
		"remaining_levels": max(0, LEVEL_SEQUENCE.size() - display_index),
		"game_started": _game_started,
		"display_progress": "{0}/{1}".format([display_index, LEVEL_SEQUENCE.size()])
	}

## 檢查是否已完成所有關卡
func is_sequence_completed() -> bool:
	return _current_level_index >= LEVEL_SEQUENCE.size()

## 便利方法：直接進入下一關（使用 CoreManager）
func goto_next_level():
	var next_level = advance_to_next_level()
	if CoreManager:
		await CoreManager.goto_scene(next_level)
	else:
		printerr("CoreManager 不可用")

## 便利方法：開始遊戲（從第一關開始）
func start_game():
	reset_progress()
	_current_level_index = 0 # 設定到第一關
	_game_started = true
	var first_level = get_current_level()
	print("開始遊戲，進入關卡: ", first_level)
	if CoreManager:
		await CoreManager.goto_scene(first_level)
	else:
		printerr("CoreManager 不可用")

## 便利方法：回到標題畫面
func return_to_title():
	reset_progress()
	if CoreManager:
		await CoreManager.goto_scene("Title")
	else:
		printerr("CoreManager 不可用")

## 獲取關卡在序列中的出現次數（統計用）
func get_level_count(level_name: String) -> int:
	var count = 0
	for level in LEVEL_SEQUENCE:
		if level == level_name:
			count += 1
	return count

## 獲取所有唯一關卡名稱
func get_unique_levels() -> Array[String]:
	var unique_levels: Array[String] = []
	for level in LEVEL_SEQUENCE:
		if not unique_levels.has(level):
			unique_levels.append(level)
	return unique_levels

## 調試用：打印當前狀態
func debug_print_status():
	var info = get_progress_info()
	print("=== LevelManager 狀態 ===")
	print("當前關卡: ", info.current_level)
	print("下一關: ", info.next_level)
	print("進度: ", info.display_progress, " ({0:.1f}%)".format([info.progress_percentage]))
	print("關卡序列: ", LEVEL_SEQUENCE)
	print("========================")

extends Node
# LevelManager - 關卡管理器 (AutoLoad)
# 管理關卡的順序和進度

signal level_completed(current_level: String, next_level: String)
signal sequence_completed()

## 關卡順序配置
## 可在編輯器中設定或通過代碼修改
var LEVEL_SEQUENCE: Array[String] = [
	"Level1",
	"Level1",
	"GoddessWeaponSelect",
	"Level1",
	"Level1",
	"Level1"
]

## 當前關卡索引
var _current_level_index: int = -1 # 初始化為 -1 表示遊戲還未開始

## 是否已經開始遊戲
var _game_started: bool = false

## 是否已經初始化
var _initialized: bool = false

func _ready() -> void:
	_initialized = true
	print("✓ LevelManager (AutoLoad) 已初始化")

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

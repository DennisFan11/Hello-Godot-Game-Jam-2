extends CanvasLayer
# GlobalDebugUI - 全域調試介面 (AutoLoad)
# 保持在最高層，提供調試功能

## UI 節點
var debug_panel: Panel
var scene_name_label: Label
var level_status_label: Label
var enemy_kill_label: Label
var start_game_button: Button
var next_level_button: Button
var reset_progress_button: Button

## 是否顯示調試UI
var _debug_ui_visible: bool = true

func _ready() -> void:
	# 設定最高層級
	layer = 100
	
	# 創建調試UI
	_create_debug_ui()
	
	print("✓ GlobalDebugUI (AutoLoad) 已初始化")

func _create_debug_ui():
	# 主面板 - 位於中右方
	debug_panel = Panel.new()
	debug_panel.name = "DebugPanel"
	debug_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	debug_panel.position.x -= 250 # 向左偏移一些
	debug_panel.size = Vector2(240, 230) # 增加高度以容納擊殺數量顯示
	debug_panel.modulate = Color(1, 1, 1, 0.9) # 稍微透明
	add_child(debug_panel)
	
	# 垂直容器
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	debug_panel.add_child(vbox)
	
	# 標題
	var title_label = Label.new()
	title_label.text = "Debug UI"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title_label)
	
	# 當前場景名稱
	scene_name_label = Label.new()
	scene_name_label.text = "場景: " + _get_current_scene_name()
	scene_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_name_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(scene_name_label)
	
	# LevelManager 狀態
	level_status_label = Label.new()
	level_status_label.name = "LevelStatusLabel"
	level_status_label.text = "載入中..."
	level_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_status_label.add_theme_font_size_override("font_size", 10)
	level_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(level_status_label)
	
	# 敵人擊殺數量顯示
	enemy_kill_label = Label.new()
	enemy_kill_label.name = "EnemyKillLabel"
	enemy_kill_label.text = "擊殺: 0/0"
	enemy_kill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_kill_label.add_theme_font_size_override("font_size", 12)
	enemy_kill_label.add_theme_color_override("font_color", Color.RED)
	vbox.add_child(enemy_kill_label)
	
	# 分隔線
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# 開始遊戲按鈕
	start_game_button = Button.new()
	start_game_button.text = "開始遊戲"
	start_game_button.pressed.connect(_on_start_game_pressed)
	vbox.add_child(start_game_button)
	
	# 下一關按鈕
	next_level_button = Button.new()
	next_level_button.text = "下一關"
	next_level_button.pressed.connect(_on_next_level_pressed)
	vbox.add_child(next_level_button)
	
	# 重置進度按鈕
	reset_progress_button = Button.new()
	reset_progress_button.text = "重置進度"
	reset_progress_button.pressed.connect(_on_reset_progress_pressed)
	vbox.add_child(reset_progress_button)
	
	# 隱藏/顯示按鈕
	var toggle_button = Button.new()
	toggle_button.text = "隱藏調試UI"
	toggle_button.pressed.connect(_on_toggle_debug_ui)
	vbox.add_child(toggle_button)

func _process(_delta: float) -> void:
	# 更新場景名稱
	if scene_name_label:
		scene_name_label.text = "場景: " + _get_current_scene_name()
	
	# 更新 LevelManager 狀態
	_update_level_manager_status()
	
	# 更新敵人擊殺數量
	_update_enemy_kill_status()

func _update_level_manager_status():
	if not level_status_label:
		return
	
	if LevelManager:
		var info = LevelManager.get_progress_info()
		level_status_label.text = "當前: {0}\n下一關: {1}\n進度: {2}".format([
			info.current_level,
			info.next_level,
			info.display_progress
		])
	else:
		level_status_label.text = "LevelManager 未載入"

func _update_enemy_kill_status():
	if not enemy_kill_label:
		return
	
	if LevelManager:
		var current_kills = LevelManager._current_enemy_dead_count
		var required_kills = 0
		
		# 使用 _current_level_index 從 KILLS_REQUIRED 數組獲取當前關卡所需擊殺數
		var level_index = LevelManager._current_level_index
		if level_index >= 0 and level_index < LevelManager.KILLS_REQUIRED.size():
			required_kills = LevelManager.KILLS_REQUIRED[level_index]
		
		enemy_kill_label.text = "擊殺: {0}/{1}".format([current_kills, required_kills])
		
		# 根據進度改變顏色
		if current_kills >= required_kills and required_kills > 0:
			enemy_kill_label.add_theme_color_override("font_color", Color.GREEN)
		elif current_kills > 0:
			enemy_kill_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			enemy_kill_label.add_theme_color_override("font_color", Color.RED)
	else:
		enemy_kill_label.text = "擊殺: 未載入"
		enemy_kill_label.add_theme_color_override("font_color", Color.GRAY)

func _get_current_scene_name() -> String:
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.name
	return "未知"

## 按鈕事件處理
func _on_start_game_pressed():
	print("調試: 開始遊戲")
	if LevelManager:
		LevelManager.start_game()
	else:
		printerr("LevelManager 不可用")

func _on_next_level_pressed():
	print("調試: 前往下一關")
	if LevelManager:
		LevelManager.goto_next_level()
	else:
		printerr("LevelManager 不可用")

func _on_reset_progress_pressed():
	print("調試: 重置進度")
	if LevelManager:
		LevelManager.reset_progress()
		LevelManager.debug_print_status()
	else:
		printerr("LevelManager 不可用")

func _on_toggle_debug_ui():
	_debug_ui_visible = not _debug_ui_visible
	debug_panel.visible = _debug_ui_visible
	
	var toggle_button = debug_panel.get_node_or_null("VBoxContainer/Button4")
	if toggle_button:
		toggle_button.text = "顯示調試UI" if not _debug_ui_visible else "隱藏調試UI"

## 快捷鍵支持
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC 鍵
		_on_toggle_debug_ui()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				_on_start_game_pressed()
			KEY_F2:
				_on_next_level_pressed()
			KEY_F3:
				_on_reset_progress_pressed()
			KEY_F4:
				if LevelManager:
					LevelManager.debug_print_status()

## 公開方法：顯示/隱藏調試UI
func show_debug_ui():
	_debug_ui_visible = true
	if debug_panel:
		debug_panel.visible = true

func hide_debug_ui():
	_debug_ui_visible = false
	if debug_panel:
		debug_panel.visible = false

func toggle_debug_ui():
	_on_toggle_debug_ui()

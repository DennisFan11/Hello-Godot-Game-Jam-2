extends Node2D

# 完整的升級系統測試場景
# 使用 DI 注入升級系統

# 依賴注入 - 將自動被 DI 系統注入
var _player_upgrade_system

# UI 元件
@onready var info_panel: Panel
@onready var status_labels: VBoxContainer
@onready var upgrade_panel: Panel
@onready var upgrade_buttons: VBoxContainer
@onready var control_panel: Panel
@onready var control_buttons: VBoxContainer

# UI 標籤
var level_label: Label
var exp_label: Label
var points_label: Label
var health_label: Label
var attack_label: Label
var speed_label: Label
var jump_label: Label
var cooldown_label: Label

func _ready():
	print("=== 完整升級系統測試開始 ===")
	
	# 創建 UI
	_create_ui()
	
	# 等待 DI 注入完成
	await get_tree().process_frame
	
	# 檢查是否成功獲取升級系統
	if _player_upgrade_system == null:
		_player_upgrade_system = CoreManager.get_upgrade_system()
	
	if _player_upgrade_system != null:
		print("✓ 升級系統已準備就緒")
		_setup_upgrade_system()
		_update_ui()
		_game_start()
	else:
		print("❌ 升級系統獲取失敗")

func _on_injected():
	"""DI 注入完成後的回調"""
	print("✓ 升級系統已通過 DI 注入")
	if _player_upgrade_system:
		_setup_upgrade_system()
		_update_ui()
		_game_start()

func _setup_upgrade_system():
	"""設置升級系統事件連接"""
	# 連接信號
	_player_upgrade_system.stats_updated.connect(_on_stats_updated)
	_player_upgrade_system.level_up.connect(_on_level_up)
	_player_upgrade_system.upgrade_applied.connect(_on_upgrade_applied)
	
	print("✓ 升級系統事件連接完成")

func _create_ui():
	print("創建 UI 界面...")
	
	# 創建信息面板
	_create_info_panel()
	
	# 創建升級面板
	_create_upgrade_panel()
	
	# 創建控制面板
	_create_control_panel()
	
	print("✓ UI 界面創建完成")

func _create_info_panel():
	# 信息面板
	info_panel = Panel.new()
	info_panel.name = "InfoPanel"
	info_panel.position = Vector2(20, 20)
	info_panel.size = Vector2(300, 250)
	add_child(info_panel)
	
	# 標題
	var title = Label.new()
	title.text = "玩家狀態"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 18)
	info_panel.add_child(title)
	
	# 狀態標籤容器
	status_labels = VBoxContainer.new()
	status_labels.position = Vector2(10, 40)
	status_labels.size = Vector2(280, 200)
	info_panel.add_child(status_labels)
	
	# 創建狀態標籤
	level_label = Label.new()
	exp_label = Label.new()
	points_label = Label.new()
	health_label = Label.new()
	attack_label = Label.new()
	speed_label = Label.new()
	jump_label = Label.new()
	cooldown_label = Label.new()
	
	status_labels.add_child(level_label)
	status_labels.add_child(exp_label)
	status_labels.add_child(points_label)
	status_labels.add_child(HSeparator.new())
	status_labels.add_child(health_label)
	status_labels.add_child(attack_label)
	status_labels.add_child(speed_label)
	status_labels.add_child(jump_label)
	status_labels.add_child(cooldown_label)

func _create_upgrade_panel():
	# 升級面板
	upgrade_panel = Panel.new()
	upgrade_panel.name = "UpgradePanel"
	upgrade_panel.position = Vector2(340, 20)
	upgrade_panel.size = Vector2(400, 400)
	add_child(upgrade_panel)
	
	# 標題
	var title = Label.new()
	title.text = "升級選項"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 18)
	upgrade_panel.add_child(title)
	
	# 升級按鈕容器
	upgrade_buttons = VBoxContainer.new()
	upgrade_buttons.position = Vector2(10, 40)
	upgrade_buttons.size = Vector2(380, 350)
	upgrade_panel.add_child(upgrade_buttons)

func _create_control_panel():
	# 控制面板
	control_panel = Panel.new()
	control_panel.name = "ControlPanel"
	control_panel.position = Vector2(20, 290)
	control_panel.size = Vector2(300, 180)
	add_child(control_panel)
	
	# 標題
	var title = Label.new()
	title.text = "測試控制"
	title.position = Vector2(10, 10)
	title.add_theme_font_size_override("font_size", 18)
	control_panel.add_child(title)
	
	# 控制按鈕容器
	control_buttons = VBoxContainer.new()
	control_buttons.position = Vector2(10, 40)
	control_buttons.size = Vector2(280, 130)
	control_panel.add_child(control_buttons)
	
	# 創建控制按鈕
	var gain_exp_btn = Button.new()
	gain_exp_btn.text = "獲得 100 經驗值"
	gain_exp_btn.pressed.connect(_on_gain_exp_pressed)
	control_buttons.add_child(gain_exp_btn)
	
	var gain_big_exp_btn = Button.new()
	gain_big_exp_btn.text = "獲得 500 經驗值"
	gain_big_exp_btn.pressed.connect(_on_gain_big_exp_pressed)
	control_buttons.add_child(gain_big_exp_btn)
	
	var reset_btn = Button.new()
	reset_btn.text = "重置升級"
	reset_btn.pressed.connect(_on_reset_pressed)
	control_buttons.add_child(reset_btn)
	
	var quit_btn = Button.new()
	quit_btn.text = "退出測試"
	quit_btn.pressed.connect(_on_quit_pressed)
	control_buttons.add_child(quit_btn)

func _update_ui():
	if not _player_upgrade_system:
		return
	
	var stats = _player_upgrade_system.player_stats
	
	# 更新狀態標籤
	level_label.text = "等級: " + str(stats.level)
	exp_label.text = "經驗值: " + str(stats.experience_points)
	points_label.text = "升級點數: " + str(stats.upgrade_points)
	health_label.text = "生命值: " + str(stats.current_health) + "/" + str(stats.max_health)
	attack_label.text = "攻擊力: " + str(stats.attack_damage)
	speed_label.text = "移動速度: " + str(stats.move_speed)
	jump_label.text = "跳躍力: " + str(stats.jump_power)
	cooldown_label.text = "技能冷卻縮減: " + str(stats.skill_cooldown_reduction)
	
	# 更新升級按鈕
	_update_upgrade_buttons()

func _update_upgrade_buttons():
	# 清除現有按鈕
	for child in upgrade_buttons.get_children():
		child.queue_free()
	
	# 等待一幀確保節點被刪除
	await get_tree().process_frame
	
	# 創建新的升級按鈕
	for upgrade_type in _player_upgrade_system.UpgradeType.values():
		var info = _player_upgrade_system.get_upgrade_info(upgrade_type)
		
		# 升級信息標籤
		var info_label = Label.new()
		info_label.text = "%s (Lv.%d/%d)" % [info.name, info.current_level, info.max_level]
		upgrade_buttons.add_child(info_label)
		
		# 升級按鈕
		var button = Button.new()
		button.text = "升級 - 消耗 %d 點" % info.cost
		button.disabled = not info.can_upgrade
		button.pressed.connect(_on_upgrade_pressed.bind(upgrade_type))
		upgrade_buttons.add_child(button)
		
		# 說明標籤
		var desc_label = Label.new()
		desc_label.text = "  " + info.description
		desc_label.modulate = Color.GRAY
		upgrade_buttons.add_child(desc_label)
		
		# 分隔線
		upgrade_buttons.add_child(HSeparator.new())

func _on_stats_updated(_stats):
	_update_ui()

func _on_level_up(new_level: int):
	print("🎉 恭喜升級到等級 ", new_level, "！")
	
	# 升級特效
	var tween = create_tween()
	tween.tween_property(level_label, "modulate", Color.GOLD, 0.3)
	tween.tween_property(level_label, "modulate", Color.WHITE, 0.3)

func _on_upgrade_applied(upgrade_type, new_level: int):
	var upgrade_name = _player_upgrade_system.upgrade_configs[upgrade_type].name
	print("✨ 升級完成: ", upgrade_name, " 等級 ", new_level)

func _on_gain_exp_pressed():
	print("獲得 100 經驗值...")
	_player_upgrade_system.gain_experience(100)

func _on_gain_big_exp_pressed():
	print("獲得 500 經驗值...")
	_player_upgrade_system.gain_experience(500)

func _on_reset_pressed():
	print("重置升級...")
	_player_upgrade_system.reset_upgrades()

func _on_quit_pressed():
	print("測試結束")
	get_tree().quit()

func _on_upgrade_pressed(upgrade_type):
	var success = _player_upgrade_system.apply_upgrade(upgrade_type)
	if success:
		print("升級成功！")
	else:
		print("升級失敗：點數不足或已達最大等級")

func _input(event):
	if not _player_upgrade_system:
		return
	
	# 鍵盤快捷鍵
	if event.is_action_pressed("ui_accept"): # Enter
		_on_gain_exp_pressed()
	elif event.is_action_pressed("ui_cancel"): # ESC
		_on_quit_pressed()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_on_upgrade_pressed(_player_upgrade_system.UpgradeType.HEALTH)
			KEY_2:
				_on_upgrade_pressed(_player_upgrade_system.UpgradeType.ATTACK)
			KEY_3:
				_on_upgrade_pressed(_player_upgrade_system.UpgradeType.SPEED)
			KEY_4:
				_on_upgrade_pressed(_player_upgrade_system.UpgradeType.JUMP)
			KEY_5:
				_on_upgrade_pressed(_player_upgrade_system.UpgradeType.COOLDOWN_REDUCTION)
			KEY_R:
				_on_reset_pressed()

# 遊戲開始時調用
func _game_start():
	print("完整測試場景開始")
	print("\n=== 操作說明 ===")
	print("🖱️  使用按鈕進行操作")
	print("⌨️  快捷鍵:")
	print("   Enter: 獲得經驗值")
	print("   1-5: 快速升級對應項目")
	print("   R: 重置升級")
	print("   ESC: 退出")
	print("===================")

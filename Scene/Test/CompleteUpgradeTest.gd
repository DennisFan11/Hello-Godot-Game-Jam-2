extends Node2D

# 完整的升級系統測試場景
# 使用 AutoLoad 單例

# UI 標籤
var level_label: Label
var exp_label: Label
var points_label: Label
var health_label: Label
var attack_label: Label

func _ready():
	print("=== 完整升級系統測試開始 ===")
	
	# 創建 UI
	_create_ui()
	
	# 等待一幀確保 UI 初始化完成
	await get_tree().process_frame
	
	print("✓ 升級系統已準備就緒")
	_setup_upgrade_system()
	_update_ui()

func _setup_upgrade_system():
	"""設置升級系統事件連接"""
	# 連接信號
	PlayerUpgradeSystem.stats_updated.connect(_on_stats_updated)
	PlayerUpgradeSystem.level_up.connect(_on_level_up)
	PlayerUpgradeSystem.upgrade_applied.connect(_on_upgrade_applied)
	
	print("✓ 升級系統事件連接完成")

func _create_ui():
	print("創建 UI 界面...")
	
	# 創建簡單的狀態顯示
	var info_panel = Panel.new()
	info_panel.position = Vector2(20, 20)
	info_panel.size = Vector2(300, 200)
	add_child(info_panel)
	
	var y_pos = 10
	level_label = Label.new()
	level_label.position = Vector2(10, y_pos)
	info_panel.add_child(level_label)
	
	y_pos += 25
	exp_label = Label.new()
	exp_label.position = Vector2(10, y_pos)
	info_panel.add_child(exp_label)
	
	y_pos += 25
	points_label = Label.new()
	points_label.position = Vector2(10, y_pos)
	info_panel.add_child(points_label)
	
	y_pos += 25
	health_label = Label.new()
	health_label.position = Vector2(10, y_pos)
	info_panel.add_child(health_label)
	
	y_pos += 25
	attack_label = Label.new()
	attack_label.position = Vector2(10, y_pos)
	info_panel.add_child(attack_label)
	
	# 測試按鈕
	var gain_exp_btn = Button.new()
	gain_exp_btn.text = "獲得 100 經驗"
	gain_exp_btn.position = Vector2(350, 20)
	gain_exp_btn.size = Vector2(120, 30)
	gain_exp_btn.pressed.connect(_on_gain_exp_pressed)
	add_child(gain_exp_btn)
	
	var upgrade_btn = Button.new()
	upgrade_btn.text = "升級生命值"
	upgrade_btn.position = Vector2(350, 60)
	upgrade_btn.size = Vector2(120, 30)
	upgrade_btn.pressed.connect(_on_upgrade_health_pressed)
	add_child(upgrade_btn)
	
	print("✓ UI 界面創建完成")

func _update_ui():
	if not PlayerUpgradeSystem:
		return
	
	var stats = PlayerUpgradeSystem.player_stats
	level_label.text = "等級: %d" % stats.level
	exp_label.text = "經驗: %d" % stats.experience_points
	points_label.text = "升級點數: %d" % stats.upgrade_points
	health_label.text = "生命值: %d/%d" % [stats.current_health, stats.max_health]
	attack_label.text = "攻擊力: %d" % stats.attack_damage

func _on_stats_updated(_stats):
	_update_ui()

func _on_level_up(new_level: int):
	print("🎉 等級提升到: ", new_level)

func _on_upgrade_applied(upgrade_type: int, new_level: int):
	print("✅ 升級完成: 類型 %d, 新等級 %d" % [upgrade_type, new_level])

func _on_gain_exp_pressed():
	PlayerUpgradeSystem.gain_experience(100)
	print("✅ 獲得 100 經驗")

func _on_upgrade_health_pressed():
	var success = PlayerUpgradeSystem.apply_upgrade(PlayerUpgradeSystem.UpgradeType.HEALTH)
	if success:
		print("✅ 生命值升級成功")
	else:
		print("❌ 升級失敗：可能缺少升級點數或已達最高等級")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

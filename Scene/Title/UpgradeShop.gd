extends Control

# 升級商店場景 - 讓玩家自由選擇升級項目

# 升級類型常量
const UPGRADE_HEALTH = 0
const UPGRADE_ATTACK = 1
const UPGRADE_SPEED = 2
const UPGRADE_JUMP = 3
const UPGRADE_COOLDOWN_REDUCTION = 4

# AutoLoad 單例引用
var upgrade_system
var inventory_system

# UI 節點引用
@onready var player_points_label = $VBoxContainer/HeaderPanel/PlayerPointsLabel
@onready var upgrade_items_container = $VBoxContainer/ScrollContainer/UpgradeItemsContainer
@onready var add_exp_button = $VBoxContainer/ButtonsPanel/HBoxContainer/AddExpButton
@onready var reset_button = $VBoxContainer/ButtonsPanel/HBoxContainer/ResetButton
@onready var back_to_title_button = $VBoxContainer/BackToTitleButton

func _ready():
	# 等待一幀確保 @onready 變數已初始化
	await get_tree().process_frame

	var coin = ConfigRepo.repo.get_value("PLAYER_PROPERTIES", "coins", 0)
	print("Current Coins: ", coin)
	
	# 獲取 AutoLoad 單例引用
	upgrade_system = PlayerUpgradeSystem
	inventory_system = PlayerInventorySystem
	
	# 設置系統
	_setup_upgrade_system()
	_update_shop_display()

func _setup_upgrade_system():
	"""設置升級系統事件連接"""
	# 連接升級事件
	if not upgrade_system.stats_updated.is_connected(_on_stats_updated):
		upgrade_system.stats_updated.connect(_on_stats_updated)
	if not upgrade_system.upgrade_applied.is_connected(_on_upgrade_purchased):
		upgrade_system.upgrade_applied.connect(_on_upgrade_purchased)
	
	# 連接按鈕事件
	if add_exp_button and not add_exp_button.pressed.is_connected(_on_add_exp_pressed):
		add_exp_button.pressed.connect(_on_add_exp_pressed)
	if reset_button and not reset_button.pressed.is_connected(_on_reset_pressed):
		reset_button.pressed.connect(_on_reset_pressed)
	if back_to_title_button and not back_to_title_button.pressed.is_connected(_on_back_to_title_pressed):
		back_to_title_button.pressed.connect(_on_back_to_title_pressed)

func _update_shop_display():
	"""更新商店顯示"""
	# 檢查 UI 節點是否存在
	if not player_points_label:
		print("⚠ player_points_label 節點未找到")
		return
	
	# 更新玩家點數顯示
	var points = upgrade_system.upgrade_levels.get_upgrade_point()
	var level = upgrade_system.player_stats.get_stats("level")
	var experience = upgrade_system.player_stats.get_stats("experience_points")
	
	player_points_label.text = "可用升級點數: %d | 等級: %d | 經驗: %d" % [points, level, experience]
	
	# 清除現有升級項目
	_clear_upgrade_items()
	
	# 創建升級項目
	_create_upgrade_items()

func _clear_upgrade_items():
	"""清除所有升級項目"""
	if not upgrade_items_container:
		return
	
	for child in upgrade_items_container.get_children():
		child.queue_free()

func _create_upgrade_items():
	"""創建所有升級項目的 UI"""
	if not upgrade_items_container:
		return
	
	var upgrade_levels = upgrade_system.upgrade_levels
	for upgrade_type in upgrade_levels.get_upgrade_type():
		var upgrade_info = upgrade_levels.get_upgrade_info(upgrade_type)
		_create_upgrade_item(upgrade_type, upgrade_info)

func _create_upgrade_item(upgrade_type:String, info: Dictionary):
	"""創建單個升級項目的 UI"""
	# 主容器
	var item_panel = Panel.new()
	item_panel.custom_minimum_size = Vector2(400, 140)
	item_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_items_container.add_child(item_panel)
	
	# 設置面板樣式
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.25, 0.9)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.3, 0.3, 0.5, 1)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	item_panel.add_theme_stylebox_override("panel", panel_style)
	
	# 主水平布局
	var main_hbox = HBoxContainer.new()
	main_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_hbox.add_theme_constant_override("separation", 10)
	main_hbox.add_theme_constant_override("margin_left", 10)
	main_hbox.add_theme_constant_override("margin_right", 10)
	main_hbox.add_theme_constant_override("margin_top", 10)
	main_hbox.add_theme_constant_override("margin_bottom", 10)
	item_panel.add_child(main_hbox)
	
	# 左側信息區域（佔 60% 寬度）
	var left_container = VBoxContainer.new()
	left_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_container.size_flags_stretch_ratio = 0.6
	main_hbox.add_child(left_container)
	
	# 圖標和名稱的水平布局
	var icon_name_hbox = HBoxContainer.new()
	icon_name_hbox.add_theme_constant_override("separation", 8)
	left_container.add_child(icon_name_hbox)
	
	# 圖標標籤
	var icon_label = Label.new()
	icon_label.text = info.icon
	icon_label.custom_minimum_size = Vector2(32, 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_name_hbox.add_child(icon_label)
	
	# 升級名稱
	var name_label = Label.new()
	name_label.text = "%s" % info.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	icon_name_hbox.add_child(name_label)
	
	# 等級進度
	var level_label = Label.new()
	level_label.text = "等級: %d/%d" % [info.current_level, info.max_level]
	level_label.add_theme_color_override("font_color", Color.CYAN)
	level_label.add_theme_font_size_override("font_size", 12)
	left_container.add_child(level_label)
	
	# 升級描述
	var desc_label = Label.new()
	desc_label.text = info.description
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_container.add_child(desc_label)
	
	# 升級效果顯示
	var effect_label = Label.new()
	effect_label.text = _get_upgrade_effect_text(upgrade_type, info)
	effect_label.add_theme_color_override("font_color", Color.YELLOW)
	effect_label.add_theme_font_size_override("font_size", 10)
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_container.add_child(effect_label)
	
	# 右側購買區域（佔 40% 寬度）
	var right_container = VBoxContainer.new()
	right_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_container.size_flags_stretch_ratio = 0.4
	main_hbox.add_child(right_container)
	
	# 添加頂部間距
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_container.add_child(top_spacer)
	
	# 價格標籤
	var price_label = Label.new()
	price_label.text = "消耗: %d 點" % info.cost
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_color_override("font_color", Color.ORANGE)
	price_label.add_theme_font_size_override("font_size", 12)
	right_container.add_child(price_label)
	
	# 購買按鈕
	var buy_button = Button.new()
	var button_text = ""
	var can_buy = false
	
	if info.current_level >= info.max_level:
		button_text = "已滿級"
		buy_button.disabled = true
	elif upgrade_system.upgrade_levels.get_upgrade_point() < info.cost:
		button_text = "點數不足"
		buy_button.disabled = true
	else:
		button_text = "購買升級"
		buy_button.disabled = false
		can_buy = true
	
	buy_button.text = button_text
	buy_button.custom_minimum_size = Vector2(0, 35)
	buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_button.add_theme_font_size_override("font_size", 11)
	
	# 設置按鈕樣式
	if can_buy:
		# 創建購買按鈕的樣式
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.2, 0.6, 0.3, 1)
		normal_style.border_width_left = 2
		normal_style.border_width_top = 2
		normal_style.border_width_right = 2
		normal_style.border_width_bottom = 2
		normal_style.border_color = Color(0.3, 0.8, 0.4, 1)
		normal_style.corner_radius_top_left = 5
		normal_style.corner_radius_top_right = 5
		normal_style.corner_radius_bottom_right = 5
		normal_style.corner_radius_bottom_left = 5
		
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.3, 0.8, 0.4, 1)
		hover_style.border_width_left = 2
		hover_style.border_width_top = 2
		hover_style.border_width_right = 2
		hover_style.border_width_bottom = 2
		hover_style.border_color = Color(0.4, 0.9, 0.5, 1)
		hover_style.corner_radius_top_left = 5
		hover_style.corner_radius_top_right = 5
		hover_style.corner_radius_bottom_right = 5
		hover_style.corner_radius_bottom_left = 5
		
		buy_button.add_theme_stylebox_override("normal", normal_style)
		buy_button.add_theme_stylebox_override("hover", hover_style)
		buy_button.add_theme_color_override("font_color", Color.WHITE)
	else:
		# 禁用按鈕樣式
		var disabled_style = StyleBoxFlat.new()
		disabled_style.bg_color = Color(0.3, 0.3, 0.3, 0.7)
		disabled_style.border_width_left = 1
		disabled_style.border_width_top = 1
		disabled_style.border_width_right = 1
		disabled_style.border_width_bottom = 1
		disabled_style.border_color = Color(0.5, 0.5, 0.5, 1)
		disabled_style.corner_radius_top_left = 5
		disabled_style.corner_radius_top_right = 5
		disabled_style.corner_radius_bottom_right = 5
		disabled_style.corner_radius_bottom_left = 5
		
		buy_button.add_theme_stylebox_override("disabled", disabled_style)
		buy_button.add_theme_color_override("font_color_disabled", Color.GRAY)
	
	buy_button.pressed.connect(_on_buy_upgrade.bind(upgrade_type))
	right_container.add_child(buy_button)
	
	# 添加底部間距
	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_container.add_child(bottom_spacer)

func _get_upgrade_effect_text(upgrade_type:String, info: Dictionary) -> String:
	"""獲取升級效果文字"""
	var current_level = info.current_level
	var base_value = info.base_value
	
	if current_level >= info.max_level:
		return "已達到最高等級"
	
	match upgrade_type:
		"HEALTH":
			return "下次升級: +%d 最大生命值" % base_value
		"ATTACK":
			return "下次升級: +%d 攻擊力" % base_value
		"SPEED":
			return "下次升級: +%.1f 移動速度" % base_value
		"JUMP":
			return "下次升級: +%.1f 跳躍力" % base_value
		"COOLDOWN_REDUCTION":
			return "下次升級: +%.1f%% 冷卻縮減" % (base_value * 100)
		_:
			return "升級效果未知"

func _on_buy_upgrade(upgrade_type:String):
	"""處理購買升級"""
	var success = upgrade_system.apply_upgrade(upgrade_type)
	if success:
		print("✅ 購買成功！升級了 %s" % upgrade_system.upgrade_levels.get_config(upgrade_type).name)

func _on_add_exp_pressed():
	"""測試按鈕：增加經驗值"""
	upgrade_system.gain_experience(100)

func _on_reset_pressed():
	"""重置按鈕：重置所有升級"""
	upgrade_system.reset_upgrades()

func _on_back_to_title_pressed():
	"""返回標題畫面"""
	await CoreManager.goto_scene("Title")

func _on_upgrade_purchased(upgrade_type:String, new_level: int):
	"""升級購買成功時的回調"""
	var upgrade_name = upgrade_system.upgrade_levels.get_config(upgrade_type).name
	print("🎉 已購買：%s 升級到等級 %d" % [upgrade_name, new_level])

func _on_stats_updated(_stats):
	"""玩家屬性更新時的回調"""
	_update_shop_display()

func _input(event):
	"""處理輸入事件"""
	if event.is_action_pressed("ui_cancel"): # ESC 鍵
		_on_back_to_title_pressed()

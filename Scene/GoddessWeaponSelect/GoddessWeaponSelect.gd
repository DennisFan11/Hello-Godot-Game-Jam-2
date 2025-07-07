extends Control

# 女神武器選擇場景
# 玩家進入場景後，女神會請玩家選擇起始武器

# AutoLoad 單例引用
var inventory_system # PlayerInventorySystem 的引用

# UI 節點
@onready var goddess_portrait: TextureRect = $GoddessPortrait
@onready var dialogue_panel: Panel = $DialoguePanel
@onready var dialogue_label: RichTextLabel = $DialoguePanel/DialogueContainer/DialogueLabel
@onready var continue_button: Button = $DialoguePanel/DialogueContainer/ContinueButton
@onready var weapon_selection_panel: Panel = $WeaponSelectionPanel
@onready var weapon_buttons_container: HBoxContainer = $WeaponSelectionPanel/WeaponButtonsContainer

# 女神圖片
var goddess_image: TextureRect

# 對話系統
var dialogue_texts: Array[String] = []
var ui_texts: Dictionary = {}
var weapons_config: Array[Dictionary] = []

var current_dialogue_index: int = 0
var is_dialogue_phase: bool = true
var selected_weapon: Dictionary = {}

# 文本檔案路徑
const DIALOGUE_FILE_PATH = "res://Scene/GoddessWeaponSelect/dialogue_texts.json"

# 下一個場景名稱 (對應 CoreManager 的 SCENE 字典)
const NEXT_SCENE_NAME = "Level1"

func _ready():
	print("女神武器選擇場景已載入")
	
	# 初始化 AutoLoad 單例引用
	inventory_system = PlayerInventorySystem
	
	# 載入對話文本檔案
	_load_dialogue_texts()
	
	# 初始化 UI
	_setup_ui()
	
	# 開始對話
	_start_dialogue()

func _load_dialogue_texts():
	"""載入對話文本檔案"""
	if FileAccess.file_exists(DIALOGUE_FILE_PATH):
		var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				var data = json.data
				
				# 載入對話文本
				if data.has("dialogue_texts"):
					var temp_array = data["dialogue_texts"]
					dialogue_texts.clear()
					for text in temp_array:
						if text is String:
							dialogue_texts.append(text)
				
				# 載入UI文本
				if data.has("ui_texts"):
					ui_texts = data["ui_texts"]
				
				# 載入武器配置
				if data.has("weapons"):
					var temp_weapons = data["weapons"]
					weapons_config.clear()
					for weapon in temp_weapons:
						if weapon is Dictionary:
							weapons_config.append(weapon)
				
				print("對話文本載入成功")
			else:
				print("JSON 解析失敗: ", json.get_error_message())
				print("找不到有效的對話文本")
		else:
			print("無法開啟文本檔案")
			print("找不到對話文本檔案")
	else:
		print("文本檔案不存在")
		print("找不到對話文本檔案")

func _setup_ui():
	"""設置 UI 元素"""
	# 創建女神圖片
	_create_goddess_image()
	
	# 隱藏武器選擇面板
	weapon_selection_panel.visible = false
	
	# 設置對話面板
	dialogue_panel.visible = true
	continue_button.pressed.connect(_on_continue_pressed)
	
	# 創建武器選擇按鈕
	_create_weapon_buttons()

func _create_goddess_image():
	"""創建女神圖片"""
	goddess_image = TextureRect.new()
	
	# 載入女神圖片
	var goddess_texture = load("res://Asset/Image/Goddess.png")
	if goddess_texture:
		goddess_image.texture = goddess_texture
	
	# 設置圖片屬性
	goddess_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	goddess_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 使用圖片的原始大小
	if goddess_texture:
		var original_size = goddess_texture.get_size()
		print("女神圖片原始大小: ", original_size)
	
	# 直接複製 GoddessPortrait 的錨點和偏移設置
	goddess_image.anchor_left = goddess_portrait.anchor_left
	goddess_image.anchor_top = goddess_portrait.anchor_top
	goddess_image.anchor_right = goddess_portrait.anchor_right
	goddess_image.anchor_bottom = goddess_portrait.anchor_bottom
	
	# 設置偏移，但不限制大小，讓圖片保持原始尺寸
	goddess_image.offset_left = goddess_portrait.offset_left - 100 # 向左擴展一點
	goddess_image.offset_top = goddess_portrait.offset_top + 200 # 初始在下方
	goddess_image.offset_right = goddess_portrait.offset_right + 100 # 向右擴展一點
	goddess_image.offset_bottom = goddess_portrait.offset_bottom + 400 # 增加高度空間
	
	# 設置層級（在背景之上，UI之下）
	goddess_image.z_index = 1 # 確保在背景之上，UI之下
	
	# 初始透明度設為0（完全透明）
	goddess_image.modulate.a = 0.0
	
	# 添加到場景
	add_child(goddess_image)
	
	# 調試：輸出位置信息
	print("GoddessPortrait 錨點: ", goddess_portrait.anchor_left, ", ", goddess_portrait.anchor_top)
	print("GoddessPortrait 偏移: ", goddess_portrait.offset_left, ", ", goddess_portrait.offset_top)
	print("女神圖片初始偏移: ", goddess_image.offset_left, ", ", goddess_image.offset_top)
	print("女神圖片目標偏移: ", goddess_portrait.offset_left, ", ", goddess_portrait.offset_top)

func _start_dialogue():
	"""開始對話序列"""
	current_dialogue_index = 0
	is_dialogue_phase = true
	_show_current_dialogue()

func _show_current_dialogue():
	"""顯示當前對話"""
	if current_dialogue_index < dialogue_texts.size():
		dialogue_label.text = dialogue_texts[current_dialogue_index]
		
		# 如果是第一句對話，同時淡入女神圖片
		if current_dialogue_index == 0 and goddess_image:
			_fade_in_goddess_image()
		
		# 打字機效果（簡化版）
		dialogue_label.visible_characters = 0
		var tween = create_tween()
		tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 1.5)
	else:
		# 對話結束，顯示武器選擇
		_show_weapon_selection()

func _fade_in_goddess_image():
	"""女神圖片淡入效果"""
	if goddess_image:
		# 創建一個平行動畫組
		var tween = create_tween()
		tween.set_parallel(true) # 允許同時執行多個動畫
		
		# 淡入效果 (透明度從0到1)
		tween.tween_property(goddess_image, "modulate:a", 1.0, 2.0)
		
		# 由下而上的移動效果 (使用偏移動畫到目標位置)
		var target_offset_top = goddess_portrait.offset_top - 100 # 目標位置稍微往上一點
		var target_offset_bottom = goddess_portrait.offset_bottom + 200 # 保持足夠的高度
		
		tween.tween_property(goddess_image, "offset_top", target_offset_top, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(goddess_image, "offset_bottom", target_offset_bottom, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		print("女神圖片動畫目標偏移: ", target_offset_top)

func _update_dialogue_characters(visible_count: int):
	"""更新對話顯示的字符數量（打字機效果）"""
	dialogue_label.visible_characters = visible_count

func _on_continue_pressed():
	"""繼續按鈕被按下"""
	if not is_dialogue_phase:
		return
	
	current_dialogue_index += 1
	_show_current_dialogue()

func _show_weapon_selection():
	"""顯示武器選擇界面"""
	is_dialogue_phase = false
	
	# 更新對話內容
	dialogue_label.text = ui_texts.get("weapon_selection", "請選擇你的武器：")
	continue_button.visible = false
	
	# 顯示武器選擇面板
	weapon_selection_panel.visible = true
	weapon_selection_panel.z_index = 2 # 確保武器選擇面板在女神圖片之上
	
	# 武器選擇面板淡入動畫
	weapon_selection_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(weapon_selection_panel, "modulate:a", 1.0, 0.5)

func _create_weapon_buttons():
	"""創建武器選擇按鈕"""
	for weapon in weapons_config:
		var weapon_button = _create_weapon_button(weapon)
		weapon_buttons_container.add_child(weapon_button)

func _create_weapon_button(weapon_data: Dictionary) -> Control:
	"""創建單個武器按鈕"""
	# 主容器
	var button_container = VBoxContainer.new()
	button_container.custom_minimum_size = Vector2(200, 280)
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 武器按鈕
	var weapon_button = Button.new()
	weapon_button.custom_minimum_size = Vector2(180, 200)
	weapon_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 按鈕樣式
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.3, 0.5, 0.8)
	normal_style.border_width_left = 3
	normal_style.border_width_top = 3
	normal_style.border_width_right = 3
	normal_style.border_width_bottom = 3
	normal_style.border_color = Color(0.6, 0.7, 0.9, 1.0)
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.corner_radius_bottom_left = 10
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.4, 0.6, 0.9)
	hover_style.border_width_left = 4
	hover_style.border_width_top = 4
	hover_style.border_width_right = 4
	hover_style.border_width_bottom = 4
	hover_style.border_color = Color(0.8, 0.9, 1.0, 1.0)
	hover_style.corner_radius_top_left = 10
	hover_style.corner_radius_top_right = 10
	hover_style.corner_radius_bottom_right = 10
	hover_style.corner_radius_bottom_left = 10
	
	weapon_button.add_theme_stylebox_override("normal", normal_style)
	weapon_button.add_theme_stylebox_override("hover", hover_style)
	weapon_button.add_theme_stylebox_override("pressed", hover_style)
	
	# 武器按鈕內的內容容器
	var button_content = VBoxContainer.new()
	button_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button_content.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 上方區域 - 武器圖標
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 20)
	button_content.add_child(top_spacer)
	
	# 武器圖標
	var icon_label = Label.new()
	icon_label.text = weapon_data.icon
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 72)
	button_content.add_child(icon_label)
	
	# 中間彈性間距
	var middle_spacer = Control.new()
	middle_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button_content.add_child(middle_spacer)
	
	# 武器名稱 - 位於按鈕中下方
	var name_label = Label.new()
	name_label.text = weapon_data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	button_content.add_child(name_label)
	
	# 底部間距
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 15)
	button_content.add_child(bottom_spacer)
	
	weapon_button.add_child(button_content)
	
	# 描述標籤 - 位於整個按鈕下方
	var description_label = Label.new()
	description_label.text = weapon_data.description
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.custom_minimum_size = Vector2(180, 60)
	
	# 添加到容器
	button_container.add_child(weapon_button)
	button_container.add_child(description_label)
	
	# 連接按鈕信號
	weapon_button.pressed.connect(_on_weapon_selected.bind(weapon_data))
	
	return button_container

func _on_weapon_selected(weapon_data: Dictionary):
	"""當玩家選擇武器時"""
	print("玩家選擇了武器: %s" % weapon_data.name)
	
	# 記錄選擇的武器
	selected_weapon = weapon_data
	
	# 通過背包系統添加武器 (使用變數引用)
		inventory_system.add_weapon(weapon_data.id, weapon_data.name, weapon_data.description)
	print("✓ 武器已添加到背包系統")
	
	# 隱藏武器選擇面板
	weapon_selection_panel.visible = false
	
	# 顯示女神的回應
	_show_goddess_response()

func _show_goddess_response():
	"""顯示女神對玩家選擇的回應"""
	# 顯示繼續按鈕
	continue_button.visible = true
	continue_button.text = ui_texts.get("journey_button", "踏上旅程")
	
	# 更新對話內容
	dialogue_label.text = selected_weapon.response
	
	# 打字機效果
	dialogue_label.visible_characters = 0
	var tween = create_tween()
	tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 2.0)
	
	# 更新繼續按鈕的功能
	continue_button.pressed.disconnect(_on_continue_pressed)
	continue_button.pressed.connect(_on_journey_start)

func _on_journey_start():
	"""開始旅程"""
	print("開始冒險旅程！")
	
	# 淡出效果
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# 通過 CoreManager 轉跳到下一個場景
	await CoreManager.goddess_scene_complete()

func _input(event):
	"""處理輸入事件"""
	if event.is_action_pressed("ui_accept") and is_dialogue_phase:
		_on_continue_pressed()

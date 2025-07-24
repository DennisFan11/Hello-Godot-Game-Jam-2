extends Control

# 女神武器選擇場景
# 玩家進入場景後，女神會請玩家選擇起始武器

# AutoLoad 單例引用
var inventory_system # PlayerInventorySystem 的引用

# UI 節點
@onready var goddess_portrait: TextureRect = $GoddessPortrait
@onready var dialogue_panel: Panel = $DialoguePanel
@onready var name_label: Label = $DialoguePanel/NameLabel
@onready var dialogue_label: RichTextLabel = $DialoguePanel/DialogueContainer/DialogueLabel
@onready var continue_button: Button = $DialoguePanel/DialogueContainer/ContinueButton
@onready var weapon_selection_panel: Node = $WeaponSelectionPanel
@onready var weapon_buttons_container: Node = $WeaponSelectionPanel/WeaponButtonsContainer

# 武器按鈕和描述標籤
@onready var weapon_buttons: Array[Button] = []
@onready var weapon_descriptions: Array[Label] = []

# 特殊按鈕（掉落的武器按鈕）
@onready var dropped_weapon_button: Button = $WeaponSelectionPanel/WeaponButtonsContainer/WeaponButton2Container/WeaponButton2

# 當前顯示的武器（用於隨機選擇）
var current_displayed_weapons: Array[Dictionary] = []

# 女神圖片
var goddess_image: TextureRect

# 武器圖片（掉落動畫中的武器）
var dropped_weapon_image: TextureRect

# 武器圖標（在女神圖片上浮動的圖標）
var left_weapon_icon: TextureRect
var right_weapon_icon: TextureRect

# 對話系統
var dialogue_texts: Array[Dictionary] = []
var ui_texts: Dictionary = {}
var weapons_config: Array[Dictionary] = []

var current_dialogue_index: int = 0
var current_text_index: int = 0
var is_dialogue_phase: bool = true
var selected_weapon: Dictionary = {}
var float_tween: Tween
var move_tween: Tween
var animated_icon: TextureRect

# 信號定義
signal journey_started

var _god_scene_manager: GodSceneManager
var _weapon_slot: WeaponSlot

# 文本檔案路徑
const DIALOGUE_FILE_PATH = "res://GameSystem/GodSceneManager/GoddessWeaponSelect/dialogue_texts.json"

# 下一個場景名稱 (對應 CoreManager 的 SCENE 字典)
const NEXT_SCENE_NAME = "Level1"

# 資源路徑常量
const GODDESS_IMAGE_PATH = "res://Asset/Image/Goddess.png"
const GODDESS_IMAGE_2_PATH = "res://Asset/Image/Goddess2.png"
const WEAPON_ICON_PATH = "res://icon.svg"

# 場景路徑常量
const BUTTON_PATH_TEMPLATE = "WeaponSelectionPanel/WeaponButtonsContainer/WeaponButton%dContainer/WeaponButton%d"
const DESCRIPTION_PATH_TEMPLATE = "WeaponSelectionPanel/WeaponButtonsContainer/WeaponButton%dContainer/WeaponButton%dDescription"

func _ready():
	DI.register("_god_weapon_select", self)
	dialogue_panel.visible = false
	weapon_selection_panel.visible = false
	continue_button.visible = false
	inventory_system = PlayerInventorySystem
	_load_dialogue_texts()
	_setup_ui()
	visible = false
	
func _on_injected():
	# 連接信號並等待觸發
	if (_god_scene_manager):
		_god_scene_manager.start_scene_requested.connect(_on_start_scene_requested)

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
					for dialogue_obj in temp_array:
						if dialogue_obj is Dictionary:
							dialogue_texts.append(dialogue_obj)
				
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
				
				# 保持錯誤處理的 print
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
	
	# 設置名字標籤的背景樣式
	_setup_name_label_style()
	
	# 隱藏武器選擇面板
	weapon_selection_panel.visible = false
	
	# 設置對話面板
	dialogue_panel.visible = true
	continue_button.pressed.connect(_on_continue_pressed)
	
	# 設置武器按鈕
	_setup_weapon_buttons()

func _setup_name_label_style():
	"""設置名字標籤的背景樣式"""
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 0.7)
	
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.8, 0.8, 0.8, 0.9)
	
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.corner_radius_bottom_right = 5
	
	style_box.content_margin_left = 8
	style_box.content_margin_right = 8
	style_box.content_margin_top = 4
	style_box.content_margin_bottom = 4
	
	name_label.add_theme_stylebox_override("normal", style_box)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	
var _ori_goddess_texture: Texture
func _create_goddess_image():
	"""創建女神圖片"""
	goddess_image = TextureRect.new()
	
	# 載入女神圖片
	var goddess_texture = load(GODDESS_IMAGE_PATH)
	if goddess_texture:
		goddess_image.texture = goddess_texture
		_ori_goddess_texture = goddess_texture
	
	# 設置圖片屬性
	goddess_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	goddess_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 重要：設置為忽略鼠標事件，防止攔截按鈕點擊
	goddess_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 將女神圖片作為 GoddessPortrait 的子節點，而不是直接添加到根節點
	# 這樣可以更好地控制層級結構
	goddess_image.anchors_preset = Control.PRESET_FULL_RECT
	goddess_image.anchor_left = 0.0
	goddess_image.anchor_top = 0.0
	goddess_image.anchor_right = 1.0
	goddess_image.anchor_bottom = 1.0
	
	# 設置偏移以擴展顯示區域
	goddess_image.offset_left = -100
	goddess_image.offset_top = 200 # 初始在下方
	goddess_image.offset_right = 100
	goddess_image.offset_bottom = 400
	
	# 初始透明度設為0（完全透明）
	goddess_image.modulate.a = 0.0
	
	# 添加到 GoddessPortrait 作為子節點
	goddess_portrait.add_child(goddess_image)
	

func _start_dialogue():
	"""開始對話序列"""
	current_dialogue_index = 0
	current_text_index = 0
	is_dialogue_phase = true
	
	_show_current_dialogue()

func _show_current_dialogue():
	continue_button.visible = false
	"""顯示當前對話"""
	if current_dialogue_index < dialogue_texts.size():
		print("顯示對話：", current_dialogue_index, " - ", current_text_index)
		var current_dialogue = dialogue_texts[current_dialogue_index]
		var current_speaker = current_dialogue.get("name", "")
		var current_texts = current_dialogue.get("texts", [])
		
		if current_text_index < current_texts.size():
			# 顯示說話者名字在獨立的標籤中
			if current_speaker != "":
				name_label.text = current_speaker
				name_label.visible = true
			else:
				name_label.visible = false
			
			# 對話內容不再包含名字
			dialogue_label.text = current_texts[current_text_index]
			
			# 如果是第一句對話，同時淡入女神圖片
			if current_dialogue_index == 0 and current_text_index == 0 and goddess_image:
				_fade_in_goddess_image()
			
			# 打字機效果（簡化版）
			dialogue_label.visible_characters = 0
			var tween = create_tween()
			tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 1.5)

			# 等待打字機效果完成
			await tween.finished
			# 顯示繼續按紐
			continue_button.visible = true
		else:
			# 當前對話組的所有文本都顯示完了，進入下一組
			current_dialogue_index += 1
			current_text_index = 0
			_show_current_dialogue()
	else:
		# 對話結束，顯示武器選擇
		_show_weapon_selection()

func _fade_in_goddess_image():
	"""女神圖片淡入效果"""
	if goddess_image:
		# 如果武器圖片存在，將其移動到女神圖片作為子物件
		if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
			# 從原來的父節點移除
			if dropped_weapon_image.get_parent():
				dropped_weapon_image.get_parent().remove_child(dropped_weapon_image)
			
			# 添加到女神圖片作為子物件
			goddess_image.add_child(dropped_weapon_image)
			
			# 重新設置位置到女神圖片的中上位置
			dropped_weapon_image.position = Vector2(80, -40) # 相對於女神圖片的中上位置
			dropped_weapon_image.rotation = deg_to_rad(45) # 保持45度旋轉
			
			# 顯示武器圖片並恢復透明度
			dropped_weapon_image.visible = true
			dropped_weapon_image.modulate.a = 1.0
			
			print("✓ 武器圖片已移動到女神圖片中上位置")
		
		# 女神圖片淡入動畫
		var fade_tween = create_tween()
		fade_tween.tween_property(goddess_image, "modulate:a", 1.0, 1.0)
		print("✓ 女神圖片開始淡入")
		
		# 創建一個平行動畫組
		var tween = create_tween()
		tween.set_parallel(true) # 允許同時執行多個動畫
		
		# 淡入效果 (透明度從0到1)
		tween.tween_property(goddess_image, "modulate:a", 1.0, 2.0)
		
		# 由下而上的移動效果 (現在是相對於 GoddessPortrait 的坐標)
		var target_offset_top = -100 # 相對於父節點向上移動
		var target_offset_bottom = 200 # 保持足夠的高度
		
		tween.tween_property(goddess_image, "offset_top", target_offset_top, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(goddess_image, "offset_bottom", target_offset_bottom, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		print("女神圖片動畫目標偏移: ", target_offset_top)
		print("✓ 女神圖片淡入動畫開始（相對於 GoddessPortrait）")

func _update_dialogue_characters(visible_count: int):
	"""更新對話顯示的字符數量（打字機效果）"""
	dialogue_label.visible_characters = visible_count

func _on_continue_pressed():
	"""繼續按鈕被按下"""
	if not is_dialogue_phase:
		return
	
	# 檢查當前對話組是否還有更多文本
	if current_dialogue_index < dialogue_texts.size():
		var current_dialogue = dialogue_texts[current_dialogue_index]
		var current_texts = current_dialogue.get("texts", [])
		
		if current_text_index + 1 < current_texts.size():
			# 還有更多文本，顯示下一句
			current_text_index += 1
		else:
			# 當前對話組完成，進入下一組
			current_dialogue_index += 1
			current_text_index = 0
	
	_show_current_dialogue()

func _show_weapon_selection():
	"""顯示武器選擇界面"""
	is_dialogue_phase = false
	
	# 隱藏名字標籤
	name_label.visible = false
	
	# 切換女神圖片為 Goddess2.png，使用淡入淡出效果
	if goddess_image:
		await _change_goddess_image_with_fade(GODDESS_IMAGE_2_PATH)
		
		# 添加武器圖標到女神圖片
		_add_weapon_icons_to_goddess()
	
	# 更新對話內容
	dialogue_label.text = ui_texts.get("weapon_selection", "請選擇你的武器：")
	continue_button.visible = false
	
	# 顯示武器選擇面板
	weapon_selection_panel.visible = true
	weapon_selection_panel.z_index = 10 # 確保武器選擇面板在所有其他元素之上
	
	# 顯示武器按鈕
	_show_weapon_buttons()
	
	# 武器選擇面板淡入動畫
	weapon_selection_panel.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(weapon_selection_panel, "modulate:a", 1.0, 0.5)
	

func _setup_weapon_buttons():
	"""設置武器按鈕""" # 動態查找並初始化武器按鈕和描述
	for i in range(1, 4): # 支援 3 個按鈕
		var button = get_node(BUTTON_PATH_TEMPLATE % [i, i])
		var description = get_node(DESCRIPTION_PATH_TEMPLATE % [i, i])
		
		if button and description:
			weapon_buttons.append(button)
			weapon_descriptions.append(description)
	
	# 如果武器數量超過按鈕數量，隨機選擇武器
	if weapons_config.size() > weapon_buttons.size():
		# 創建武器索引陣列並打亂
		var weapon_indices = range(weapons_config.size())
		weapon_indices.shuffle()
		
		# 選擇前N個武器（N = 按鈕數量）
		current_displayed_weapons.clear()
		for i in range(weapon_buttons.size()):
			current_displayed_weapons.append(weapons_config[weapon_indices[i]])
	else:
		# 武器數量不超過按鈕數量，使用全部武器
		current_displayed_weapons = weapons_config.duplicate()
	
	# 初始隱藏所有武器按鈕和描述
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].visible = false
		weapon_descriptions[i].visible = false
	
	# 連接按鈕信號並設置按鈕內容
	for i in range(min(current_displayed_weapons.size(), weapon_buttons.size())):
		var weapon_data = current_displayed_weapons[i]
		var button = weapon_buttons[i]
		
		# 重置按鈕狀態
		button.disabled = false
			
		# 清除舊的信號連接（如果有的話）
		if button.pressed.is_connected(_on_weapon_selected):
			button.pressed.disconnect(_on_weapon_selected)
			
		# 連接新的信號（傳遞按鈕索引）
		button.pressed.connect(_on_weapon_selected.bind(weapon_data, i))
			
		# 連接滑鼠懸停信號
		button.mouse_entered.connect(_on_weapon_button_mouse_entered.bind(i))
		button.mouse_exited.connect(_on_weapon_button_mouse_exited.bind(i))
			

	# 如果顯示的武器數量少於按鈕數量，禁用多餘的按鈕
	for i in range(current_displayed_weapons.size(), weapon_buttons.size()):
		var button = weapon_buttons[i]
		var description = weapon_descriptions[i]
		button.disabled = true
		button.text = ""
		description.text = ""
		description.visible = false


func _show_weapon_buttons():
	"""顯示武器按鈕"""
	# 只顯示有對應武器的按鈕，描述保持隱藏直到滑鼠懸停
	for i in range(min(weapons_config.size(), weapon_buttons.size())):
		weapon_buttons[i].visible = true
		weapon_descriptions[i].visible = false # 描述初始隱藏


func _hide_weapon_buttons():
	"""隱藏武器按鈕"""
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].visible = false
		weapon_descriptions[i].visible = false


func _on_weapon_selected(weapon_data: Dictionary, button_index: int):
	"""當玩家選擇武器時"""
	# 記錄選擇的武器
	selected_weapon = weapon_data

	# 印出 button_index
	print("選擇的武器按鈕索引: ", button_index)
	
	# 觸發對應武器 icon 的動畫效果
	_animate_weapon_icon_selection(button_index)
	
	# 通過背包系統添加武器 (使用變數引用)
	inventory_system.add_weapon(weapon_data.id, weapon_data.name, weapon_data.description)
	# 隱藏武器選擇面板
	weapon_selection_panel.visible = false
	
	var weapon_id: String
	if button_index == 1:
		weapon_id = "Main"
	elif button_index == 0:
		weapon_id = left_weapon.id
	else:
		weapon_id = right_weapon.id
	print("選擇的武器 ID: ", weapon_id)
	var weapon: Weapon = (
		null
		if weapon_id == "Main" else
		WeaponManager.create_weapon_scene(weapon_id))
	# 顯示女神的回應並等待完成
	await _show_goddess_response(weapon)
	_god_scene_manager._finished.emit(weapon)

func _show_goddess_response(weapon: Weapon):
	"""顯示女神對玩家選擇的回應"""
	# 隱藏名字標籤（因為回應不使用新格式）
	name_label.visible = false
	
	# 顯示繼續按鈕
	continue_button.visible = false
	continue_button.text = ui_texts.get("journey_button", "踏上旅程")
	
	# 更新對話內容
	if not weapon:
		dialogue_label.text = ui_texts.get("no_weapon_selected", "你選擇了你原本的武器。")
	else:
		dialogue_label.text = ui_texts.get("goddess_response", "你選擇的武器是：") + "\n" + weapon.name
	
	# 打字機效果
	dialogue_label.visible_characters = 0
	var tween = create_tween()
	tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 2.0)
	
	# 等待打字機效果完成
	await tween.finished
	# 顯示繼續按鈕
	continue_button.visible = true
	# 更新繼續按鈕的功能
	continue_button.pressed.disconnect(_on_continue_pressed)
	continue_button.pressed.connect(_on_journey_start)
	
	# 等待旅程開始信號
	await journey_started

func _on_journey_start():
	"""開始旅程"""
	# 發射信號，解除 _show_goddess_response 的等待
	journey_started.emit()
	
	# 清理武器圖片資源
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		dropped_weapon_image.queue_free()
		dropped_weapon_image = null
	# 淡出效果
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# 清理 animated_icon
	if animated_icon and is_instance_valid(animated_icon):
		animated_icon.queue_free()
		animated_icon = null

	# 停止 float_tween 動畫並清理
	if float_tween and is_instance_valid(float_tween):
		float_tween.stop()
		float_tween = null

	# 停止 move_tween 動畫並清理
	if move_tween and is_instance_valid(move_tween):
		move_tween.stop()
		move_tween = null

	weapon_selection_panel.visible = false
	_reset()

func _input(event):
	"""處理輸入事件"""
	if event.is_action_pressed("ui_accept") and is_dialogue_phase:
		_on_continue_pressed()

func _weapon_drop_animation():
	"""武器掉落動畫 - 自由落體效果"""
	dropped_weapon_image = TextureRect.new()

	# 從 _weapon_slot.take_first_weapon 複製一個當前的武器
	var weapon = _weapon_slot.take_first_weapon().duplicate(1 << 1 || 1 << 2 || 1 << 4 || 1 << 8)

	# weapon 的 scale 設為 5倍
	weapon.scale = Vector2(5, 5)

	dropped_weapon_image.add_child(weapon)
	# var weapon_texture = load("res://icon.svg") # 暫時使用icon作為武器圖片
	# if weapon_texture:
	# 	dropped_weapon_image.texture = weapon_texture
	
	dropped_weapon_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	dropped_weapon_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dropped_weapon_image.size = Vector2(100, 100)
	
	dropped_weapon_image.pivot_offset = dropped_weapon_image.size / 2
	
	var _screen_size = get_viewport().get_visible_rect().size
	dropped_weapon_image.position = Vector2(0, -50)
	dropped_weapon_image.rotation = deg_to_rad(45)
	
	goddess_portrait.add_child(dropped_weapon_image)
	
	var target_position = Vector2(30, 450)
	
	# 創建自由落體動畫
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 垂直位移 (自由落體，使用二次函數緩動)
	tween.tween_property(dropped_weapon_image, "position:y", target_position.y, 3.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	# 輕微的水平擺動效果
	tween.tween_method(_update_weapon_swing, 0.0, 3.0, 3.0)
	
	# 旋轉效果
	tween.tween_property(dropped_weapon_image, "rotation", PI * 2, 3.0).set_ease(Tween.EASE_OUT)
	print("✓ 武器掉落動畫開始")
	# 等待動畫完成
	await tween.finished
	
	# 觸發攝影機震動
	_screen_shake(0.4, 0.4) # 持續時間1秒，強度0.8
	
	# 撞擊效果 (輕微彈跳)
	var bounce_tween = create_tween()
	bounce_tween.tween_property(dropped_weapon_image, "position:y", target_position.y - 20, 0.2).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(dropped_weapon_image, "position:y", target_position.y, 0.3).set_ease(Tween.EASE_IN)
	
	await bounce_tween.finished
	
	# 停留一下然後淡出
	await get_tree().create_timer(0.5).timeout
	
	var fade_tween = create_tween()
	fade_tween.tween_property(dropped_weapon_image, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	
	# 先隱藏武器圖片，但不刪除它，等待 _fade_in_goddess_image 來處理
	dropped_weapon_image.visible = false
	

func _update_weapon_swing(_time: float):
	"""更新武器擺動效果"""
	# 這個方法會在動畫過程中被調用，用於實現擺動效果
	# 你可以在這裡添加更複雜的擺動邏輯
	pass

func _screen_shake(duration: float, strength: float):
	"""螢幕震動效果 - 震動整個場景"""
	var original_position = position
	
	# 創建震動動畫
	var shake_tween = create_tween()
	
	# 使用 tween_method 來控制震動過程
	shake_tween.tween_method(
		func(progress: float):
			if progress < 1.0:
				# 創建隨機震動偏移
				var shake_offset = Vector2(
					randf_range(-strength, strength) * 10,
					randf_range(-strength, strength) * 10
				)
				# 應用震動偏移
				position = original_position + shake_offset
			else:
				# 震動結束，回到原位
				position = original_position,
		0.0, 1.0, duration
	)
	
	# 確保最後回到原位
	shake_tween.tween_property(self, "position", original_position, 0.0)

func _on_weapon_button_mouse_entered(button_index: int):
	"""當滑鼠進入武器按鈕時顯示描述"""
	if button_index >= 0 and button_index < weapon_descriptions.size():
		var description = weapon_descriptions[button_index]
		if description and weapon_buttons[button_index].visible and not weapon_buttons[button_index].disabled:
			description.visible = true
			print("✓ 顯示武器按鈕 %d 的描述" % [button_index + 1])

func _on_weapon_button_mouse_exited(button_index: int):
	"""當滑鼠離開武器按鈕時隱藏描述"""
	if button_index >= 0 and button_index < weapon_descriptions.size():
		var description = weapon_descriptions[button_index]
		if description:
			description.visible = false


func _change_goddess_image_with_fade(new_texture_path: String):
	"""使用淡入淡出效果切換女神圖片"""
	if not goddess_image:
		return
	
	# 載入新的紋理
	var new_texture = load(new_texture_path)
	if not new_texture:
		print("⚠ 警告：無法載入圖片 %s，保持原始圖片" % new_texture_path)
		return
	
	# 如果 dropped_weapon_image 存在，暫時移出（無論父節點是什麼）
	var temp_dropped_weapon_parent = null
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		temp_dropped_weapon_parent = dropped_weapon_image.get_parent()
		if temp_dropped_weapon_parent:
			temp_dropped_weapon_parent.remove_child(dropped_weapon_image)
	
	# 創建一個臨時的圖片節點用於新圖片
	var temp_image = TextureRect.new()
	temp_image.texture = new_texture
	temp_image.expand_mode = goddess_image.expand_mode
	temp_image.stretch_mode = goddess_image.stretch_mode
	temp_image.mouse_filter = goddess_image.mouse_filter
	
	# 複製位置和大小設定
	temp_image.anchors_preset = goddess_image.anchors_preset
	temp_image.anchor_left = goddess_image.anchor_left
	temp_image.anchor_top = goddess_image.anchor_top
	temp_image.anchor_right = goddess_image.anchor_right
	temp_image.anchor_bottom = goddess_image.anchor_bottom
	temp_image.offset_left = goddess_image.offset_left
	temp_image.offset_top = goddess_image.offset_top
	temp_image.offset_right = goddess_image.offset_right
	temp_image.offset_bottom = goddess_image.offset_bottom
	
	# 新圖片初始透明度為0
	temp_image.modulate.a = 0.0
	
	# 將新圖片添加到同一個父節點
	goddess_portrait.add_child(temp_image)
	
	# 創建同時執行的動畫
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 舊圖片淡出
	tween.tween_property(goddess_image, "modulate:a", 0.0, 0.5)
	# 新圖片淡入
	tween.tween_property(temp_image, "modulate:a", 1.0, 0.5)
	
	await tween.finished
	
	# 移除舊圖片節點
	goddess_image.queue_free()
	
	# 將新圖片設為當前女神圖片
	goddess_image = temp_image
	
	# 如果 dropped_weapon_image 存在，重新添加到新的女神圖片
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		goddess_image.add_child(dropped_weapon_image)

var left_weapon: Weapon
var right_weapon: Weapon
func _add_weapon_icons_to_goddess():
	"""為女神圖片添加兩個武器圖標作為子物件"""
	if not goddess_image:
		return
	
	var left_id: String = WeaponManager.get_random_weapon_id()
	var right_id: String = WeaponManager.get_random_weapon_id()

	left_weapon = WeaponManager.create_weapon_scene(left_id)
	# 將 left_weapon 的 scale 設置為 5 倍
	left_weapon.scale = Vector2(5, 5)

	right_weapon = WeaponManager.create_weapon_scene(right_id)
	# 將 right_weapon 的 scale 設置為 5 倍
	right_weapon.scale = Vector2(5, 5)

	weapon_buttons[0].text = left_weapon.id
	weapon_descriptions[0].text = left_weapon.id
	weapon_buttons[1].text = "你掉的武器"
	weapon_buttons[2].text = right_weapon.id
	weapon_descriptions[2].text = right_weapon.id

	
	# 設置左側位置（左中）
	left_weapon.position = Vector2(-50, 250) # 相對於女神圖片的左中位置
	
	# 設置右側位置（右中）
	right_weapon.position = Vector2(300, 250) # 相對於女神圖片的右中位置
	
	# 添加到女神圖片作為子物件
	goddess_image.add_child(left_weapon)
	goddess_image.add_child(right_weapon)
	
	# 創建淡入動畫
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 左右武器圖標同時淡入
	tween.tween_property(left_weapon, "modulate:a", 1.0, 0.8)
	tween.tween_property(right_weapon, "modulate:a", 1.0, 0.8)
	
	# 添加輕微的浮動效果
	tween.tween_property(left_weapon, "position:y", left_weapon.position.y - 10, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(right_weapon, "position:y", right_weapon.position.y - 10, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	# 創建持續的浮動動畫循環
	_start_weapon_icons_floating_animation(left_weapon, right_weapon)
	

func _start_weapon_icons_floating_animation(left_icon: Weapon, right_icon: Weapon):
	"""開始武器圖標的持續浮動動畫"""
	if not left_icon or not right_icon:
		return
	
	# 記錄初始位置
	var left_base_y = left_icon.position.y
	var right_base_y = right_icon.position.y
	
	# 創建無限循環的浮動動畫
	float_tween = create_tween()
	float_tween.set_loops() # 無限循環
	float_tween.set_parallel(true)
	
	# 左側武器圖標浮動（向上向下）
	float_tween.tween_method(
		func(y_offset): left_icon.position.y = left_base_y + y_offset,
		0.0, -15.0, 2.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	float_tween.tween_method(
		func(y_offset): left_icon.position.y = left_base_y + y_offset,
		-15.0, 0.0, 2.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(2.0)
	
	# 右側武器圖標浮動（稍微錯開時間）
	float_tween.tween_method(
		func(y_offset): right_icon.position.y = right_base_y + y_offset,
		0.0, -15.0, 2.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(1.0)
	
	float_tween.tween_method(
		func(y_offset): right_icon.position.y = right_base_y + y_offset,
		-15.0, 0.0, 2.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(3.0)
	

func _animate_weapon_icon_selection(button_index: int):
	"""當玩家選擇武器時，播放對應武器 icon 的動畫效果"""
	var source_icon: TextureRect = null
	
	# 根據按鈕索引決定使用哪個 icon
	# button_index: 0 -> left_weapon_icon, 1 -> dropped_weapon_image, 2 -> right_weapon_icon
	match button_index:
		0:
			source_icon = left_weapon_icon
		1:
			source_icon = dropped_weapon_image
		2:
			source_icon = right_weapon_icon
	
	if not source_icon:
		return
	
	# 創建一個複製的 icon 用於動畫，保持原始 icon 在女神圖片上
	animated_icon = TextureRect.new()
	animated_icon.texture = source_icon.texture
	animated_icon.expand_mode = source_icon.expand_mode
	animated_icon.stretch_mode = source_icon.stretch_mode
	animated_icon.size = source_icon.size
	animated_icon.rotation = source_icon.rotation
	animated_icon.pivot_offset = source_icon.pivot_offset
	animated_icon.modulate = source_icon.modulate
	animated_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 設置初始位置（與原始 icon 相同的全局位置）
	animated_icon.global_position = source_icon.global_position
	
	# 添加到場景的最頂層
	add_child(animated_icon)
	
	# 設置更高的 z_index 確保在最上層
	animated_icon.z_index = 100
	

	# 創建移動和縮放動畫
	move_tween = create_tween()
	move_tween.set_parallel(true)
	
	var target_position = Vector2(450, 200)
	var target_scale = Vector2(2.5, 2.5)
	
	# 動畫持續時間
	var animation_duration = 1.2
	
	# 位置動畫（加上彈性效果）
	move_tween.tween_property(animated_icon, "global_position", target_position, animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# 縮放動畫
	move_tween.tween_property(animated_icon, "scale", target_scale, animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# 旋轉動畫（恢復到 0 度）
	move_tween.tween_property(animated_icon, "rotation", 0.0, animation_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# 添加一點發光效果（透過 modulate）
	animated_icon.modulate = Color(1.2, 1.2, 1.2, 1.0) # 稍微變亮
	move_tween.tween_property(animated_icon, "modulate", Color(1.0, 1.0, 1.0, 1.0), animation_duration * 0.5).set_delay(animation_duration * 0.5)
	
	# 動畫完成後清理複製的 icon
	await move_tween.finished

func _on_start_scene_requested():
	visible = true
	# 淡入效果
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await fade_tween.finished
	print("開始場景請求已收到，執行武器掉落動畫和對話")
	"""當收到開始場景信號時執行武器掉落動畫和對話"""
	await _weapon_drop_animation()
	_start_dialogue()

func _reset():
	"""重置 GoddessPortrait 狀態"""
	
	# 重置變數
	dropped_weapon_image = null
	animated_icon = null
	float_tween = null
	move_tween = null
	
	current_dialogue_index = 0
	current_text_index = 0
	is_dialogue_phase = false
	
	selected_weapon = {}
	
	# 隱藏 UI 元素
	# name_label.text = ""
	# name_label.visible = false
	# dialogue_label.text = ""
	# dialogue_label.visible_characters = 0
	# continue_button.visible = false
	# weapon_selection_panel.visible = false

	# 重製對話
	dialogue_label.text = ""
	name_label.text = ""
	continue_button.text = "繼續"
	continue_button.visible = false
	weapon_selection_panel.visible = false
	weapon_selection_panel.z_index = 0

	continue_button.pressed.disconnect(_on_journey_start)
	continue_button.pressed.connect(_on_continue_pressed)

	goddess_image.texture = _ori_goddess_texture
	goddess_image.modulate.a = 0.0
	goddess_image.offset_top = 200 # 初始在下方
	goddess_image.offset_bottom = 400
	# 釋放 left_weapon
	if left_weapon and is_instance_valid(left_weapon):
		left_weapon.queue_free()
		left_weapon = null
	# 釋放 right_weapon
	if right_weapon and is_instance_valid(right_weapon):
		right_weapon.queue_free()
		right_weapon = null
	
	print("GoddessPortrait 已重置")

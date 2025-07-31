extends Control

# 女神武器選擇場景
# 玩家進入場景後，女神會請玩家選擇起始武器

# AutoLoad 單例引用
var inventory_system # PlayerInventorySystem 的引用

# UI 節點
@onready var goddess_portrait: TextureRect = $GoddessPortrait
@onready var goddess_image: TextureRect = $GoddessPortrait/GoddessImage
@onready var dropped_weapon_image: TextureRect = $GoddessPortrait/DroppedWeaponImage
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

# 武器圖標（在女神圖片上浮動的圖標）
var left_weapon_icon: TextureRect
var right_weapon_icon: TextureRect

# 對話系統
var dialogue_data: Array[Dictionary] = []

# 遊戲狀態相關變數（用於決定顯示哪個對話）
# var weapons_count: int = 0
var lake_state: int = 0
# var meetings_count: int = 1

var current_dialogue_index: int = 0
var current_text_index: int = 0
var is_dialogue_phase: bool = true
var selected_weapon: Dictionary = {}
var float_tween: Tween
var move_tween: Tween
var animated_icon: TextureRect
var _god_scene_manager: GodSceneManager

# 文本檔案路徑
const DIALOGUE_FILE_PATH = "res://GameSystem/GodSceneManager/GoddessWeaponSelect/dialogue_texts.json"

# 下一個場景名稱 (對應 CoreManager 的 SCENE 字典)
const NEXT_SCENE_NAME = "Level1"

# 資源路徑常量
const GODDESS_IMAGE_PATH = "res://Asset/Image/Goddess.png"
const GODDESS_IMAGE_2_PATH = "res://Asset/Image/Goddess2.png"
const GODDESS_IMAGE_ROOT_PATH = "res://Asset/Image/Goddess/"
const WEAPON_ICON_PATH = "res://icon.svg"

# 場景路徑常量
const BUTTON_PATH_TEMPLATE = "WeaponSelectionPanel/WeaponButtonsContainer/WeaponButton%dContainer/WeaponButton%d"
const DESCRIPTION_PATH_TEMPLATE = "WeaponSelectionPanel/WeaponButtonsContainer/WeaponButton%dContainer/WeaponButton%dDescription"

var main_weapon

func _ready():
	DI.register("_god_weapon_select", self)
	dialogue_panel.visible = false
	weapon_selection_panel.visible = false
	continue_button.visible = false
	inventory_system = PlayerInventorySystem
	_load_dialogue_texts()
	_setup_ui()
	visible = false

func set_god_scene_manager(node: GodSceneManager):
	_god_scene_manager = node

func _load_dialogue_texts():
	"""載入對話文本檔案"""
	var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
	if not file:
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_text) != OK:
		return
	
	var raw_data = json.data
	if raw_data is Array:
		dialogue_data.clear()
		for item in raw_data:
			if item is Dictionary:
				dialogue_data.append(item)

func _get_current_dialogue() -> Dictionary:
	"""根據遊戲狀態獲取當前對話"""
	for dialogue in dialogue_data:
		if _matches_dialogue_conditions(dialogue):
			return dialogue
	
	return {}

func _matches_dialogue_conditions(dialogue: Dictionary) -> bool:
	"""檢查對話是否符合當前遊戲狀態"""
	# 檢查武器數量
	var weapon_counts = str(dialogue.get("weapons_count", "")).split(",")
	var weapon_match = false

	var weapon_count = 0
	var w = main_weapon
	while w:
		weapon_count += 1
		w = w.next_weapon

	for count in weapon_counts:
		if count.strip_edges() == str(weapon_count):
			weapon_match = true
			break
	
	if not weapon_match:
		return false

	# 檢查湖泊狀態
	var lake_states = str(dialogue.get("lake_state", "")).split(",")
	var lake_match = false
	for state in lake_states:
		if state.strip_edges() == str(lake_state):
			lake_match = true
			break
	if not lake_match:
		return false
	
	# 檢查見面次數
	var meeting_counts = str(dialogue.get("meetings_count", "")).split(",")
	var meeting_match = false
	var meetings_count = InGameSaveSystem.load_object("meetings_count")
	if not meetings_count:
		meetings_count = 0
	for count in meeting_counts:
		var count_str = count.strip_edges()
		if count_str.begins_with(">"):
			var threshold = int(count_str.substr(1))
			if meetings_count > threshold:
				meeting_match = true
				break
		elif count_str == str(meetings_count):
			meeting_match = true
			break
	return meeting_match

func _get_dialogue_text(stage: String) -> Dictionary:
	"""獲取當前狀態下的對話文本"""
	var current_dialogue = _get_current_dialogue()
	if current_dialogue.is_empty():
		return {"talk": "預設對話", "mood": ""}
	
	return current_dialogue.get(stage, {"talk": "找不到對話文本", "mood": ""})

func _replace_text_variables(text: String) -> String:
	"""替換文本中的變數佔位符"""
	var result = text
	
	# 替換玩家武器
	if main_weapon:
		var weapon_name = main_weapon.NAME if main_weapon.NAME != "" else main_weapon.id
		result = result.replace("{玩家武器}", weapon_name)
	
	# 替換武器A和武器B（左右武器）
	if left_weapon:
		var weapon_name = left_weapon.NAME if left_weapon.NAME != "" else left_weapon.id
		result = result.replace("{武器A}", weapon_name)
	if right_weapon:
		var weapon_name = right_weapon.NAME if right_weapon.NAME != "" else right_weapon.id
		result = result.replace("{武器B}", weapon_name)
	
	# 替換玩家選擇的武器
	if selected_weapon.has("name"):
		result = result.replace("{玩家選擇武器}", str(selected_weapon.name))
	
	return result

# 使用範例函數
func _show_dialogue_stage(stage: String):
	"""顯示特定階段的對話（使用新架構的範例）"""
	var dialogue_info = _get_dialogue_text(stage)
	var text = _replace_text_variables(dialogue_info.talk)
	var mood = dialogue_info.mood
	
	dialogue_label.text = text
	# 這裡可以根據 mood 來改變女神的表情或狀態
	print("顯示對話: ", text, " (心情: ", mood, ")")
	# 從 GODDESS_IMAGE_ROOT_PATH 獲取女神圖片
	var goddess_image_path = GODDESS_IMAGE_ROOT_PATH + mood + ".png"
	goddess_image.texture = load(goddess_image_path)
	# 打字機效果（簡化版）
	dialogue_label.visible_characters = 0
	var tween = create_tween()
	tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 1.5)

	# 等待打字機效果完成
	await tween.finished
	continue_button.visible = true
	# 等待繼續按鈕被按下
	await continue_button.pressed
	continue_button.visible = false

func _setup_ui():
	"""設置 UI 元素"""
	# 設置女神圖片初始狀態
	_setup_goddess_image()
	
	# 隱藏武器選擇面板
	weapon_selection_panel.visible = false
	
	# 設置對話面板
	dialogue_panel.visible = true
	
	# 設置武器按鈕
	_setup_weapon_buttons()


var _ori_goddess_texture: Texture
func _setup_goddess_image():
	"""設置女神圖片初始狀態"""
	# 載入女神圖片並保存原始紋理
	var goddess_texture = load(GODDESS_IMAGE_PATH)
	if goddess_texture:
		goddess_image.texture = goddess_texture
		_ori_goddess_texture = goddess_texture
	
	# 設置圖片屬性（這些在 .tscn 中已經設置，但可以確保正確）
	goddess_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	goddess_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	goddess_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 設置初始透明度為0（完全透明）
	goddess_image.modulate.a = 0.0
	

func _start_dialogue():
	"""開始對話序列"""
	current_dialogue_index = 0
	current_text_index = 0
	is_dialogue_phase = true

	_prepare_weapon_selection()
	await _show_dialogue_stage("talk1")
	_fade_in_goddess_image()
	await _show_dialogue_stage("talk2")
	await _show_dialogue_stage("talk3")
	_show_weapon_selection()

func _fade_in_goddess_image():
	"""女神圖片淡入效果"""
	if goddess_image:
		# 如果武器圖片存在，將其移動到女神圖片作為子物件
		if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
			# 從 GoddessPortrait 移除並添加到女神圖片作為子物件
			goddess_portrait.remove_child(dropped_weapon_image)
			goddess_image.add_child(dropped_weapon_image)
			
			# 重新設置位置到女神圖片的中上位置
			dropped_weapon_image.position = Vector2(80, -40) # 相對於女神圖片的中上位置
			dropped_weapon_image.rotation_degrees = 45 # 保持45度旋轉
			
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

func _prepare_weapon_selection():
	var left_id: String = WeaponManager.get_random_weapon_id()
	var right_id: String = WeaponManager.get_random_weapon_id()
	
	# 确保左右武器ID不相同
	while right_id == left_id:
		right_id = WeaponManager.get_random_weapon_id()

	left_weapon = WeaponManager.create_weapon_scene(left_id)
	left_weapon.scale = Vector2(5, 5)
	left_weapon.position = Vector2(-50, 250)
	right_weapon = WeaponManager.create_weapon_scene(right_id)
	right_weapon.scale = Vector2(5, 5)
	right_weapon.position = Vector2(300, 250)
	var node2d = goddess_image.get_node("Node2D")
	left_weapon.move_to(node2d, %GlueLayer)
	right_weapon.move_to(node2d, %GlueLayer)
	weapon_buttons[0].text = left_weapon.NAME
	weapon_descriptions[0].text = left_weapon.DESC
	weapon_buttons[1].text = "你掉的武器"
	weapon_buttons[2].text = right_weapon.NAME
	weapon_descriptions[2].text = right_weapon.DESC
	left_weapon.visible = false
	right_weapon.visible = false

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
	dialogue_label.text = "請選擇你的武器："
	
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
	
	# 初始隱藏所有武器按鈕和描述
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].visible = false
		weapon_descriptions[i].visible = false
	
	# 連接按鈕信號並設置按鈕內容
	for i in range(weapon_buttons.size()):
		# var weapon_data = current_displayed_weapons[i]
		var button = weapon_buttons[i]
		
		# 重置按鈕狀態
		button.disabled = false
			
		# 清除舊的信號連接（如果有的話）
		if button.pressed.is_connected(_on_weapon_selected):
			button.pressed.disconnect(_on_weapon_selected)
			
		# 連接新的信號（傳遞按鈕索引）
		button.pressed.connect(_on_weapon_selected.bind(i))

		# 連接滑鼠懸停信號
		button.mouse_entered.connect(_on_weapon_button_mouse_entered.bind(i))
		button.mouse_exited.connect(_on_weapon_button_mouse_exited.bind(i))

func _show_weapon_buttons():
	"""顯示武器按鈕"""
	# 顯示所有weapon_buttons
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].visible = true
		weapon_descriptions[i].visible = false # 描述初始隱藏


func _hide_weapon_buttons():
	"""隱藏武器按鈕"""
	for i in range(weapon_buttons.size()):
		weapon_buttons[i].visible = false
		weapon_descriptions[i].visible = false


func _on_weapon_selected(button_index: int):
	"""當玩家選擇武器時"""
	# 印出 button_index
	print("選擇的武器按鈕索引: ", button_index)
	
	# 觸發對應武器 icon 的動畫效果
	_animate_weapon_icon_selection(button_index)
	
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
	if not weapon:
		await _show_dialogue_stage("talk4-1")
	else:
		await _show_dialogue_stage("talk4-2")
	# 顯示女神的回應並等待完成
	await _on_journey_start()
	_god_scene_manager.end_event(main_weapon, weapon)

func _on_journey_start():
	"""開始旅程"""
	# 淡出效果，讓畫面漸漸變暗
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.5, 0.8)
	await tween.finished
	
	# 呼叫重置方法來清理所有狀態
	_reset()

func _weapon_drop_animation():
	"""武器掉落動畫 - 自由落體效果"""
	# 使用預定義的 TextureRect 節點
	
	main_weapon.move_to(dropped_weapon_image, null, false)
	# weapon 的 scale 設為 5倍
	main_weapon.scale = Vector2(5, 5)

	
	# 設置 TextureRect 屬性
	dropped_weapon_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	dropped_weapon_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dropped_weapon_image.size = Vector2(100, 100)
	dropped_weapon_image.pivot_offset = dropped_weapon_image.size / 2
	
	# 設置初始位置和旋轉
	dropped_weapon_image.position = Vector2(0, -50)
	dropped_weapon_image.rotation_degrees = 45
	
	# 顯示節點
	dropped_weapon_image.visible = true
	
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
	
	# 如果 dropped_weapon_image 存在，暫時移出
	var temp_dropped_weapon_parent = null
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		temp_dropped_weapon_parent = dropped_weapon_image.get_parent()
		if temp_dropped_weapon_parent:
			temp_dropped_weapon_parent.remove_child(dropped_weapon_image)
	
	# 創建淡出淡入動畫
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 淡出到完全透明
	tween.tween_property(goddess_image, "modulate:a", 0.0, 0.25)
	
	await tween.finished
	
	# 更換紋理
	goddess_image.texture = new_texture
	
	# 淡入新圖片
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(goddess_image, "modulate:a", 1.0, 0.25)
	
	await fade_in_tween.finished
	
	# 如果 dropped_weapon_image 存在，重新添加到女神圖片
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		goddess_image.add_child(dropped_weapon_image)

var left_weapon: Weapon
var right_weapon: Weapon
func _add_weapon_icons_to_goddess():
	"""為女神圖片添加兩個武器圖標作為子物件"""
	if not goddess_image:
		return
	
	left_weapon.visible = true
	right_weapon.visible = true

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

func start_scene():
	visible = true
	main_weapon = WeaponManager.get_player_weapon()
	# 淡入效果
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	await fade_tween.finished
	print("開始場景請求已收到，執行武器掉落動畫和對話")
	await _weapon_drop_animation()
	_start_dialogue()

func _reset():
	"""重置 GoddessPortrait 狀態"""
	
	# 清理動畫相關變數
	if animated_icon and is_instance_valid(animated_icon):
		animated_icon.queue_free()
		animated_icon = null

	# 停止所有動畫並清理
	if float_tween and is_instance_valid(float_tween):
		float_tween.stop()
		float_tween = null

	if move_tween and is_instance_valid(move_tween):
		move_tween.stop()
		move_tween = null
	
	# 重置對話系統變數
	current_dialogue_index = 0
	current_text_index = 0
	is_dialogue_phase = false
	selected_weapon = {}
	
	# 重置 dropped_weapon_image 節點
	if dropped_weapon_image and is_instance_valid(dropped_weapon_image):
		dropped_weapon_image.visible = false
		goddess_portrait.add_child(dropped_weapon_image)
	
	# 重置 UI 元素
	dialogue_label.text = ""
	name_label.text = ""
	continue_button.text = "繼續"
	continue_button.visible = false
	weapon_selection_panel.visible = false
	weapon_selection_panel.z_index = 0

	# 重置女神圖片
	goddess_image.texture = _ori_goddess_texture
	goddess_image.modulate.a = 0.0
	goddess_image.offset_top = 200 # 初始在下方
	goddess_image.offset_bottom = 400
	
	# 釋放武器物件
	if left_weapon and is_instance_valid(left_weapon):
		left_weapon.queue_free()
		left_weapon = null
	if right_weapon and is_instance_valid(right_weapon):
		right_weapon.queue_free()
		right_weapon = null
	
	print("GoddessPortrait 已重置")

#extends Control
#
## 女神武器選擇場景
## 玩家進入場景後，女神會請玩家選擇起始武器
#
## AutoLoad 單例引用
#var inventory_system # PlayerInventorySystem 的引用
#
## UI 節點
#
## 女神圖片
#var goddess_image: TextureRect
#
## 對話系統
#
## 文本檔案路徑
#const DIALOGUE_FILE_PATH = "res://GameSystem/GoddessWeaponSelect/dialogue_texts.json"
#
## 下一個場景名稱 (對應 CoreManager 的 SCENE 字典)
#const NEXT_SCENE_NAME = "Level1"
#
#func _ready():
	#print("女神武器選擇場景已載入")
	#
	## 初始化 AutoLoad 單例引用
	#inventory_system = PlayerInventorySystem
	#
	## 載入對話文本檔案
	#_load_dialogue_texts()
	#
	## 初始化 UI
	#_setup_ui()
	#
	## 開始對話
	#_start_dialogue()
#
#func _load_dialogue_texts():
	#"""載入對話文本檔案"""
	#if FileAccess.file_exists(DIALOGUE_FILE_PATH):
		#var file = FileAccess.open(DIALOGUE_FILE_PATH, FileAccess.READ)
		#if file:
			#var json_text = file.get_as_text()
			#file.close()
			#
			#var json = JSON.new()
			#var parse_result = json.parse(json_text)
			#
			#if parse_result == OK:
				#var data = json.data
				#
				## 載入對話文本
				#if data.has("dialogue_texts"):
					#var temp_array = data["dialogue_texts"]
					#dialogue_texts.clear()
					#for text in temp_array:
						#if text is String:
							#dialogue_texts.append(text)
				#
				## 載入UI文本
				#if data.has("ui_texts"):
					#ui_texts = data["ui_texts"]
				#
				## 載入武器配置
				#if data.has("weapons"):
					#var temp_weapons = data["weapons"]
					#weapons_config.clear()
					#for weapon in temp_weapons:
						#if weapon is Dictionary:
							#weapons_config.append(weapon)
				#
				#print("✓ 對話文本載入成功")
				#print("✓ 載入了 %d 個對話文本" % dialogue_texts.size())
				#print("✓ 載入了 %d 個武器配置" % weapons_config.size())
				#
				## 列出載入的武器
				#for i in range(weapons_config.size()):
					#var weapon = weapons_config[i]
					#print("  - 武器 %d: %s (%s)" % [i + 1, weapon.name, weapon.id])
			#else:
				#print("JSON 解析失敗: ", json.get_error_message())
				#print("找不到有效的對話文本")
		#else:
			#print("無法開啟文本檔案")
			#print("找不到對話文本檔案")
	#else:
		#print("文本檔案不存在")
		#print("找不到對話文本檔案")
#
#func _setup_ui():
	#"""設置 UI 元素"""
	## 創建女神圖片
	#_create_goddess_image()
	#
	## 隱藏武器選擇面板
	#weapon_selection_panel.visible = false
	#
	## 設置對話面板
	#dialogue_panel.visible = true
	#continue_button.pressed.connect(_on_continue_pressed)
	#
	## 設置武器按鈕
	#_setup_weapon_buttons()
#
#func _create_goddess_image():
	#"""創建女神圖片"""
	#goddess_image = TextureRect.new()
	#
	## 載入女神圖片
	#var goddess_texture = load("res://Asset/Image/Goddess.png")
	#if goddess_texture:
		#goddess_image.texture = goddess_texture
	#
	## 設置圖片屬性
	#goddess_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	#goddess_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#
	## 重要：設置為忽略鼠標事件，防止攔截按鈕點擊
	#goddess_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#
	## 使用圖片的原始大小
	#if goddess_texture:
		#var original_size = goddess_texture.get_size()
		#print("女神圖片原始大小: ", original_size)
	#
	## 將女神圖片作為 GoddessPortrait 的子節點，而不是直接添加到根節點
	## 這樣可以更好地控制層級結構
	#goddess_image.anchors_preset = Control.PRESET_FULL_RECT
	#goddess_image.anchor_left = 0.0
	#goddess_image.anchor_top = 0.0
	#goddess_image.anchor_right = 1.0
	#goddess_image.anchor_bottom = 1.0
	#
	## 設置偏移以擴展顯示區域
	#goddess_image.offset_left = -100
	#goddess_image.offset_top = 200 # 初始在下方
	#goddess_image.offset_right = 100
	#goddess_image.offset_bottom = 400
	#
	## 初始透明度設為0（完全透明）
	#goddess_image.modulate.a = 0.0
	#
	## 添加到 GoddessPortrait 作為子節點
	#goddess_portrait.add_child(goddess_image)
	#
	## 調試：輸出位置信息
	#print("GoddessPortrait 錨點: ", goddess_portrait.anchor_left, ", ", goddess_portrait.anchor_top)
	#print("GoddessPortrait 偏移: ", goddess_portrait.offset_left, ", ", goddess_portrait.offset_top)
	#print("女神圖片相對偏移: ", goddess_image.offset_left, ", ", goddess_image.offset_top)
	#print("✓ 女神圖片已設置為忽略鼠標事件")
	#print("✓ 女神圖片已添加為 GoddessPortrait 的子節點")
#
#func _start_dialogue():
	#"""開始對話序列"""
	#current_dialogue_index = 0
	#is_dialogue_phase = true
	#_show_current_dialogue()
#
#func _show_current_dialogue():
	#"""顯示當前對話"""
	#if current_dialogue_index < dialogue_texts.size():
		#dialogue_label.text = dialogue_texts[current_dialogue_index]
		#
		## 如果是第一句對話，同時淡入女神圖片
		#if current_dialogue_index == 0 and goddess_image:
			#_fade_in_goddess_image()
		#
		## 打字機效果（簡化版）
		#dialogue_label.visible_characters = 0
		#var tween = create_tween()
		#tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 1.5)
	#else:
		## 對話結束，顯示武器選擇
		#_show_weapon_selection()
#
#func _fade_in_goddess_image():
	#"""女神圖片淡入效果"""
	#if goddess_image:
		## 創建一個平行動畫組
		#var tween = create_tween()
		#tween.set_parallel(true) # 允許同時執行多個動畫
		#
		## 淡入效果 (透明度從0到1)
		#tween.tween_property(goddess_image, "modulate:a", 1.0, 2.0)
		#
		## 由下而上的移動效果 (現在是相對於 GoddessPortrait 的坐標)
		#var target_offset_top = -100 # 相對於父節點向上移動
		#var target_offset_bottom = 200 # 保持足夠的高度
		#
		#tween.tween_property(goddess_image, "offset_top", target_offset_top, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		#tween.tween_property(goddess_image, "offset_bottom", target_offset_bottom, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		#
		#print("女神圖片動畫目標偏移: ", target_offset_top)
		#print("✓ 女神圖片淡入動畫開始（相對於 GoddessPortrait）")
#
#func _update_dialogue_characters(visible_count: int):
	#"""更新對話顯示的字符數量（打字機效果）"""
	#dialogue_label.visible_characters = visible_count
#
#func _on_continue_pressed():
	#"""繼續按鈕被按下"""
	#if not is_dialogue_phase:
		#return
	#
	#current_dialogue_index += 1
	#_show_current_dialogue()
#
#func _show_weapon_selection():
	#"""顯示武器選擇界面"""
	#is_dialogue_phase = false
	#
	## 更新對話內容
	#dialogue_label.text = ui_texts.get("weapon_selection", "請選擇你的武器：")
	#continue_button.visible = false
	#
	## 顯示武器選擇面板
	#weapon_selection_panel.visible = true
	#weapon_selection_panel.z_index = 10 # 確保武器選擇面板在所有其他元素之上
	#
	## 顯示武器按鈕
	#_show_weapon_buttons()
	#
	## 武器選擇面板淡入動畫
	#weapon_selection_panel.modulate.a = 0.0
	#var tween = create_tween()
	#tween.tween_property(weapon_selection_panel, "modulate:a", 1.0, 0.5)
	#
	#print("✓ 武器選擇面板已顯示，z_index 設置為 10")
#
#func _setup_weapon_buttons():
	#pass
#func _hide_weapon_buttons():
	#pass
#
#func _on_weapon_selected(weapon_data: Dictionary):
	#"""當玩家選擇武器時"""
	#print("玩家選擇了武器: %s" % weapon_data.name)
	#
	## 記錄選擇的武器
	#selected_weapon = weapon_data
	#
	## 通過背包系統添加武器 (使用變數引用)
	#inventory_system.add_weapon(weapon_data.id, weapon_data.name, weapon_data.description)
	#print("✓ 武器已添加到背包系統")
	#
	## 隱藏武器選擇面板
	#_hide_weapon_buttons()
	#
	## 顯示女神的回應
	#_show_goddess_response()
#
#func _show_goddess_response():
	#"""顯示女神對玩家選擇的回應"""
	## 顯示繼續按鈕
	#continue_button.visible = true
	#continue_button.text = ui_texts.get("journey_button", "踏上旅程")
	#
	## 更新對話內容
	#dialogue_label.text = selected_weapon.response
	#
	## 打字機效果
	#dialogue_label.visible_characters = 0
	#var tween = create_tween()
	#tween.tween_method(_update_dialogue_characters, 0, dialogue_label.get_total_character_count(), 2.0)
	#
	## 更新繼續按鈕的功能
	#continue_button.pressed.disconnect(_on_continue_pressed)
	#continue_button.pressed.connect(_on_journey_start)
#
#func _on_journey_start():
	#"""開始旅程"""
	#print("開始冒險旅程！")
	#
	## 淡出效果
	#var tween = create_tween()
	#tween.tween_property(self, "modulate:a", 0.0, 1.0)
	#await tween.finished
	#$".."._end_event.emit()
	#
#
#func _input(event):
	#"""處理輸入事件"""
	#if event.is_action_pressed("ui_accept") and is_dialogue_phase:
		#_on_continue_pressed()

extends Node

# 玩家背包系統 - AutoLoad 單例
# 負責管理玩家的武器、道具等物品
# 作為 AutoLoad 單例存在，跨場景持續存在

signal weapon_added(weapon_data: Dictionary)
signal weapon_selected(weapon_id: String)
signal inventory_changed()

# 玩家背包數據
var _inventory: Dictionary = {
	"weapons": [],
	"selected_weapon": null,
	"items": []
}

func _ready():
	print("✓ PlayerInventorySystem (AutoLoad) 已初始化")

# =================== 武器管理 ===================

func add_weapon(weapon_id: String, weapon_name: String, weapon_description: String = "") -> Dictionary:
	"""添加武器到玩家背包"""
	var weapon_data = {
		"id": weapon_id,
		"name": weapon_name,
		"description": weapon_description,
		"obtained_time": Time.get_datetime_string_from_system()
	}
	
	# 檢查是否已存在相同ID的武器
	for weapon in _inventory.weapons:
		if weapon.id == weapon_id:
			print("⚠️ 武器已存在: %s" % weapon_name)
			return weapon
	
	_inventory.weapons.append(weapon_data)
	
	# 如果這是第一個武器，自動設為選中武器
	if _inventory.selected_weapon == null:
		_inventory.selected_weapon = weapon_id
		weapon_selected.emit(weapon_id)
	
	print("✅ 獲得武器: %s" % weapon_name)
	weapon_added.emit(weapon_data)
	inventory_changed.emit()
	return weapon_data

func set_selected_weapon(weapon_id: String) -> bool:
	"""設置選中的武器"""
	# 檢查武器是否存在
	for weapon in _inventory.weapons:
		if weapon.id == weapon_id:
			_inventory.selected_weapon = weapon_id
			print("✅ 切換武器: %s" % weapon.name)
			weapon_selected.emit(weapon_id)
			return true
	
	print("❌ 武器不存在: %s" % weapon_id)
	return false

func get_selected_weapon() -> Dictionary:
	"""獲取當前選中的武器"""
	if _inventory.selected_weapon == null:
		return {}
	
	for weapon in _inventory.weapons:
		if weapon.id == _inventory.selected_weapon:
			return weapon
	
	return {}

func get_weapons() -> Array:
	"""獲取所有武器列表"""
	return _inventory.weapons.duplicate()

func has_weapon(weapon_id: String) -> bool:
	"""檢查是否擁有指定武器"""
	for weapon in _inventory.weapons:
		if weapon.id == weapon_id:
			return true
	return false

func remove_weapon(weapon_id: String) -> bool:
	"""移除武器（謹慎使用）"""
	for i in range(_inventory.weapons.size()):
		if _inventory.weapons[i].id == weapon_id:
			var removed_weapon = _inventory.weapons[i]
			_inventory.weapons.remove_at(i)
			
			# 如果移除的是選中武器，需要重新選擇
			if _inventory.selected_weapon == weapon_id:
				if _inventory.weapons.size() > 0:
					_inventory.selected_weapon = _inventory.weapons[0].id
					weapon_selected.emit(_inventory.selected_weapon)
				else:
					_inventory.selected_weapon = null
			
			print("✅ 移除武器: %s" % removed_weapon.name)
			inventory_changed.emit()
			return true
	
	print("❌ 找不到要移除的武器: %s" % weapon_id)
	return false

# =================== 道具管理 ===================

func add_item(item_id: String, item_name: String, quantity: int = 1) -> Dictionary:
	"""添加道具到背包"""
	# 檢查是否已存在相同道具
	for item in _inventory.items:
		if item.id == item_id:
			item.quantity += quantity
			print("✅ 增加道具: %s x%d (總計: %d)" % [item_name, quantity, item.quantity])
			inventory_changed.emit()
			return item
	
	# 新道具
	var item_data = {
		"id": item_id,
		"name": item_name,
		"quantity": quantity,
		"obtained_time": Time.get_datetime_string_from_system()
	}
	
	_inventory.items.append(item_data)
	print("✅ 獲得道具: %s x%d" % [item_name, quantity])
	inventory_changed.emit()
	return item_data

func remove_item(item_id: String, quantity: int = 1) -> bool:
	"""移除指定數量的道具"""
	for item in _inventory.items:
		if item.id == item_id:
			if item.quantity >= quantity:
				item.quantity -= quantity
				print("✅ 使用道具: %s x%d (剩餘: %d)" % [item.name, quantity, item.quantity])
				
				# 如果數量為0，移除道具
				if item.quantity <= 0:
					_inventory.items.erase(item)
					print("✅ 道具已用完: %s" % item.name)
				
				inventory_changed.emit()
				return true
			else:
				print("❌ 道具數量不足: %s (需要: %d, 擁有: %d)" % [item.name, quantity, item.quantity])
				return false
	
	print("❌ 找不到道具: %s" % item_id)
	return false

func get_item_quantity(item_id: String) -> int:
	"""獲取道具數量"""
	for item in _inventory.items:
		if item.id == item_id:
			return item.quantity
	return 0

func get_items() -> Array:
	"""獲取所有道具列表"""
	return _inventory.items.duplicate()

# =================== 背包管理 ===================

func get_inventory() -> Dictionary:
	"""獲取完整背包數據"""
	return _inventory.duplicate()

func clear_inventory():
	"""清空背包（測試用）"""
	_inventory = {
		"weapons": [],
		"selected_weapon": null,
		"items": []
	}
	print("✅ 背包已清空")
	inventory_changed.emit()

func reset_inventory():
	"""重置背包（測試用）- 別名方法"""
	clear_inventory()

func get_inventory_summary() -> String:
	"""獲取背包摘要信息"""
	var summary = "背包摘要:\n"
	summary += "武器數量: %d\n" % _inventory.weapons.size()
	summary += "道具數量: %d\n" % _inventory.items.size()
	
	if _inventory.selected_weapon:
		var selected = get_selected_weapon()
		summary += "當前武器: %s" % selected.get("name", "未知")
	
	return summary

# =================== 數據持久化 ===================

func save_inventory_data() -> Dictionary:
	"""保存背包數據（用於存檔）"""
	return _inventory.duplicate()

func load_inventory_data(data: Dictionary):
	"""載入背包數據（用於讀檔）"""
	if data.has("weapons") and data.has("items"):
		_inventory = data.duplicate()
		print("✅ 背包數據已載入")
		inventory_changed.emit()
	else:
		print("❌ 背包數據格式錯誤")

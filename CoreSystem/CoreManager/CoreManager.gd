extends Node
# CORE MANAGER 可以在此取得 GameSystem

var SCENE := {
	"Title": {
		"file": preload("uid://bg4ji6py6jgn8")
	},
	"Level1": {
		"file": preload("uid://jghh2wj4o126")
	},
	"UpgradeShop": {
		"file": preload("uid://c0p31kfgvdkkq")
	},
	"Endding": {
		"file": preload("uid://cv2bm6xikqx7q")
	},
	"GoddessWeaponSelect": {
		"file": preload("uid://d0t4w5bfhv8jn")
	}
}

var TRANSITION := {
	"Triangle": preload("uid://cql8o1y2hvpls")
}

## how to use: 
# CoreManager.goto_scene("GameScene").enter_game()
# CoreManager.goto_scene("Menu").exit_game()

func goto_scene(scene: String, trans: String = "Triangle"):
	if not SCENE.has(scene):
		printerr('CoreManager.goto_scene({0}): 無效目標'.format([scene]))
		return self
	
	await _call_transition(trans, true)
	
	var scene_file = SCENE[scene]["file"]
	var result = OK
	
	# 支持預加載的場景和字符串路徑
	if scene_file is String:
		result = get_tree().change_scene_to_file(scene_file)
	else:
		result = get_tree().change_scene_to_packed(scene_file)
	
	if result != OK:
		printerr('CoreManager.goto_scene({0}): 場景載入失敗'.format([scene]))
		return self
		
	await _call_transition(trans, false)
	
	if get_tree().current_scene.has_method("_transition_end"):
		get_tree().current_scene._transition_end()
	
	return self


## PRIVATE
var _transition_cache = {}
func _call_transition(trans: String, type: bool) -> Signal:
	if not _transition_cache.has(trans) or !is_instance_valid(_transition_cache[trans]):
		_transition_cache[trans] = TRANSITION[trans].instantiate()
		add_child(_transition_cache[trans])
	var node = _transition_cache[trans]
	if type:
		node._in()
		return node.in_end
	else:
		node._out()
		return node.out_end

## GAME MANAGER

# 升級系統管理
var _player_upgrade_system: PlayerUpgradeSystem = null

# 玩家背包系統管理
var _player_inventory_system: PlayerInventorySystem = null

func _ready():
	print("CoreManager 正在初始化...")
	
	# 初始化升級系統
	_initialize_upgrade_system()
	
	# 初始化背包系統
	_initialize_inventory_system()
	
	print("✓ CoreManager 初始化完成")

func _initialize_upgrade_system():
	"""初始化並註冊升級系統到 DI"""
	print("初始化升級系統...")
	
	# 創建升級系統實例
	var upgrade_system_script = preload("uid://cehujfhv6kuj3")
	_player_upgrade_system = upgrade_system_script.new()
	
	# 將升級系統加入 CoreManager 的場景樹中
	add_child(_player_upgrade_system)
	
	# 註冊到 DI 系統
	DI.register("_player_upgrade_system", _player_upgrade_system)
	
	print("✓ 升級系統已創建並註冊到 DI 系統")

func _initialize_inventory_system():
	"""初始化並註冊背包系統到 DI"""
	print("初始化背包系統...")
	
	# 創建背包系統實例
	var inventory_system_script = preload("uid://md2r5wogehuu")
	_player_inventory_system = inventory_system_script.new()
	
	# 將背包系統加入 CoreManager 的場景樹中
	add_child(_player_inventory_system)
	
	# 註冊到 DI 系統
	DI.register("_player_inventory_system", _player_inventory_system)
	
	print("✓ 背包系統已創建並註冊到 DI 系統")

func get_upgrade_system() -> PlayerUpgradeSystem:
	"""獲取升級系統實例"""
	return _player_upgrade_system

func get_inventory_system():
	"""獲取背包系統實例"""
	return _player_inventory_system

func reset_upgrade_system():
	"""重置升級系統（測試用）"""
	if _player_upgrade_system != null:
		_player_upgrade_system.reset_upgrades()
		print("✓ 升級系統已重置")

func reset_inventory_system():
	"""重置背包系統（測試用）"""
	if _player_inventory_system != null:
		_player_inventory_system.reset_inventory()
		print("✓ 背包系統已重置")

func goddess_scene_complete():
	"""女神場景完成後的轉跳方法"""
	print("女神賜予完成，前往下一個場景...")
	# 這裡可以之後修改轉跳目標
	await goto_scene("Level1")

#

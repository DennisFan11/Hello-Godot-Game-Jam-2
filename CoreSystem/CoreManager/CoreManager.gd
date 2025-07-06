extends Node
# CORE MANAGER 可以在此取得 GameSystem

var SCENE := {
	"Title":{
		"file":preload("uid://bg4ji6py6jgn8")
	},
	"Level1":{
		"file":preload("uid://jghh2wj4o126")
	},
	"Endding":{
		"file":preload("uid://cv2bm6xikqx7q")
	}
}

var TRANSITION := {
	"Triangle":preload("uid://cql8o1y2hvpls")
}

## how to use: 
# CoreManager.goto_scene("GameScene").enter_game()
# CoreManager.goto_scene("Menu").exit_game()

func goto_scene(scene: String, trans: String="Triangle"):
	if not SCENE.has(scene):
		printerr('CoreManager.goto_scene({0}): 無效目標'.format([name]))
		return self
	
	await _call_transition(trans, true)
	if get_tree().change_scene_to_packed(SCENE[scene]["file"]) != OK:
		return
	await _call_transition(trans, false)
	
	if get_tree().current_scene.has_method("_transition_end"):
		get_tree().current_scene._transition_end()
	
	return self



## PRIVATE
var _transition_cache = {}
func _call_transition(trans: String, type: bool)-> Signal:
	
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

func _ready():
	print("CoreManager 正在初始化...")
	
	# 初始化升級系統
	_initialize_upgrade_system()
	
	print("✓ CoreManager 初始化完成")

func _initialize_upgrade_system():
	"""初始化並註冊升級系統到 DI"""
	print("初始化升級系統...")
	
	# 創建升級系統實例
	var upgrade_system_script = preload("res://GameSystem/PlayerManager/PlayerUpgradeSystem.gd")
	_player_upgrade_system = upgrade_system_script.new()
	
	# 將升級系統加入 CoreManager 的場景樹中
	add_child(_player_upgrade_system)
	
	# 註冊到 DI 系統
	DI.register("_player_upgrade_system", _player_upgrade_system)
	
	print("✓ 升級系統已創建並註冊到 DI 系統")

func get_upgrade_system() -> PlayerUpgradeSystem:
	"""獲取升級系統實例"""
	return _player_upgrade_system

func reset_upgrade_system():
	"""重置升級系統（測試用）"""
	if _player_upgrade_system != null:
		_player_upgrade_system.reset_upgrades()
		print("✓ 升級系統已重置")

#

extends Node
# CORE MANAGER 可以在此取得 GameSystem

# 場景切換信號
signal scene_changed(scene_name: String)

var SCENE := {
	"Title": {
		"file": preload("uid://bg4ji6py6jgn8")
	},
	"Tutorial":{
		"file": preload("uid://bcmasoxjfybi5")
	},
	
	"Level1": {
		"file": preload("uid://jghh2wj4o126")
	},
	"Level2": {
		"file": preload("uid://by1ilb7vws5mw")
	},
	"Level3": {
		"file": preload("uid://dmq6hvpeioana")
	},
	
	"UpgradeShop": {
		"file": preload("uid://c0p31kfgvdkkq")
	},
	"Endding": {
		"file": preload("uid://cv2bm6xikqx7q")
	},
	"GoddessWeaponSelect": {
		"file": preload("uid://dbdeoxecjlqqg")
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
		return null
		
	await _call_transition(trans, false)
	
	# 發射場景切換信號
	scene_changed.emit(scene)

	var current_scene = get_tree().current_scene
	
	if current_scene.has_method("_transition_end"):
		current_scene._transition_end()
	
	return current_scene


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

func _ready():
	print("CoreManager 正在初始化...")
	print("✓ CoreManager 初始化完成")

#

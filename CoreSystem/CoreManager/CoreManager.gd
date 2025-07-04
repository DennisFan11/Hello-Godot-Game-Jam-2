extends Node
# CORE MANAGER 可以在此取得 GameSystem

var SCENE := {
	"Title":{
		"file":preload("uid://bg4ji6py6jgn8")
	},
	"LevelSelect":{
		"file":preload("uid://fbg7a35l7a4s")
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

#

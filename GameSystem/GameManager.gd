class_name GameManager extends Node

#func _save():
	#for i:Node in get_children():
		#if i.has_method("_save"): await i._save()
#func _load():
	#for i:Node in get_children():
		#if i.has_method("_load"): await i._load()

func _game_start_recursive(parent: Node):
	for i:Node in parent.get_children():
		_game_start_recursive(i)
	if parent.has_method("_game_start"): 
		await parent._game_start()



func _ready() -> void:
	
	DI.register("_game_manager", self)
	
	## 遞歸重新注入
	DI.injection(self, true)
	
	scene_init()



## 流程圖
## _load -> _game_start ->  
func scene_init():
	#SoundManager.play_bgm_stack("game_normal")
	#await _load()
	await get_tree().process_frame
	await _game_start_recursive(self)

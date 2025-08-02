extends Node
# LevelManager - 關卡管理器 (AutoLoad)
# 管理關卡的順序和進度


## 關卡順序配置
var LEVEL_SEQUENCE: Array[String] = [
	"Level1",
	"Level2",
	"Level3",
	"SafeArea",
]

## 關卡重複次數
const LEVEL_REPEAT_COUNT = 2
func _ready() -> void:
	DI.register("_level_manager", self)
	

## PUBLIC ///////////////
var _is_start: bool = false

## 開始你的冒險 !
func start_game() -> void:
	if _is_start: return
	_is_start = true
	await _start_game()
	_is_start = false


## PRIVATE /////////////

func _start_game() -> void:
	_reset_progress()
	
	await _tutorial()
	print("Start Game")
	for cycle in range(LEVEL_REPEAT_COUNT):
		print("Cycle: ", cycle + 1)
		for level: String in LEVEL_SEQUENCE:
			var _game_manager: GameManager = await CoreManager.goto_scene(level)
			
			var player_win: bool = await _game_manager.on_end
			
			if not player_win: ## lose
				_lose()
				return
	## Win
	_win()

func _tutorial() -> void:
	var need_tutorial: bool = ConfigRepo.repo.get_value("LEVEL_MANAGER", "need_tutorial", true)
	if not need_tutorial:
		return
	
	while true:
		var _game_manager: GameManager = await CoreManager.goto_scene("Tutorial")
		
		var player_win: bool = await _game_manager.on_end
		
		if player_win:
			break
	
	ConfigRepo.repo.set_value("LEVEL_MANAGER", "need_tutorial", false)
	ConfigRepo.save()
	

func _win():
	CoreManager.goto_scene("Title")

func _lose():
	CoreManager.goto_scene("Title")

## 重置關卡進度
func _reset_progress():
	InGameSaveSystem.clear()

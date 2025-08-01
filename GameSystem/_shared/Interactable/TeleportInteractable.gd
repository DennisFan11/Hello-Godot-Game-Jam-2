extends Interactable

var _game_manager: GameManager
func interact():
	_game_manager.finish(true)

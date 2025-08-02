class_name PlayerUILayer
extends CanvasLayer


func _ready() -> void:
	%PlayerManager.player_died.connect(func(_player: Player): _show_summary_panel())
	%SummaryPanel.finish.connect(func(): _close_summary_panel())
	%TweenPanel._open()


var _player_manager: PlayerManager
var _game_manager: GameManager

func _game_start():
	_player_manager.player.health_changed.connect(
		_set_new_health
	)
	_player_manager.player.heal(0.0)


func _set_new_health(current_health: int, max_health: int):
	%HPBar.max_value = max_health
	%HPBar.value = current_health
	%HPLabel.text = "[color=green] hp: ({0}/{1})" \
		.format([current_health, max_health])

func _show_summary_panel():
	set_process_mode(PROCESS_MODE_ALWAYS)
	_game_manager.stop_game()
	%SummaryPanel._open()

func _close_summary_panel():
	set_process_mode(PROCESS_MODE_INHERIT)
	_game_manager.continue_game()
	_game_manager.finish(false)

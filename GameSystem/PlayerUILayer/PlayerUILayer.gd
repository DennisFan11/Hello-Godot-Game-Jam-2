class_name PlayerUILayer
extends CanvasLayer


func _ready() -> void:
	%TweenPanel._open()



var _player_manager: PlayerManager

func _game_start():
	_player_manager.player.health_changed.connect(
		_set_new_health
	)
	_player_manager.player.heal(0.0)


func _set_new_health(current_health: int, max_health: int):
	%HPBar.max_value = max_health
	%HPBar.value = current_health
	%HPLabel.text = "[color=green] hp: ({0}/{1})"\
		.format([current_health, max_health])


#

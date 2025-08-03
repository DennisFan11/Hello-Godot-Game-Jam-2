extends TextureRect

var show_range:int = 350

var _game_manager:GameManager
var _player_manager:PlayerManager

var teleport:Node2D
var player:Player
var rect:Rect2

func _game_start():
	DI.injection(self)
	teleport = _game_manager.get_teleport()
	player = _player_manager.player
	rect = get_viewport_rect() \
	.grow_individual(-pivot_offset.x, -pivot_offset.y, -pivot_offset.x, -pivot_offset.y)

func _process(delta: float) -> void:
	if teleport:
		var diff_pos = player.global_position - teleport.global_position
		if abs(diff_pos.x) > show_range or abs(diff_pos.y) > show_range:
			var vec = diff_pos.normalized()

			position = rect.get_center() - vec * show_range
			rotation = vec.angle()

			visible = true
		else:
			visible = false

@tool
class_name Hinter
extends Node2D




@export_multiline
var text:String = "":
	set(new):
		text = new
		if %RichTextLabel:
			%RichTextLabel.text = new

@export
var dist:float:
	set(new):
		dist = new
		if Engine.is_editor_hint():
			var arr = []
			for i in range(20):
				var angle= PI*2.0/20.0*i
				arr.append(Vector2.from_angle(angle)*dist)
			if %Line2D:
				%Line2D.points = arr

func _ready() -> void:
	if not Engine.is_editor_hint():
		if %RichTextLabel: %RichTextLabel.text = ""
		if %Line2D: %Line2D.visible = false
		await get_tree().create_timer(1.0).timeout
		DI.injection(self)
		


var _player_manager: PlayerManager
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if showed:
		return
	
	if not _player_manager:
		return
	#
	if _player_manager.get_player_position() == Vector2.ZERO:
		return
	var _dist = (_player_manager.get_player_position()-global_position).length()
	if _dist < dist:
		_show()
	
	
var showed:bool = false
	
func _show():
	#print("SHOW !!!")
	showed = true
	var tween = get_tree().create_tween()
	%RichTextLabel.text = text
	%RichTextLabel.visible_characters = 0
	for i in %RichTextLabel.get_parsed_text():
		tween.tween_callback(
			(func():
				%RichTextLabel.visible_characters += 1
				SoundManager.play_stream_sound(preload("uid://cqdotlf74tvx1"), global_position, 1.0)
				#SoundManager.play_sound("type", global_position)
				),
		).set_delay(0.05)
	tween.tween_interval(20.0)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 3.0)
	tween.tween_callback(queue_free)
	

		
	
	#

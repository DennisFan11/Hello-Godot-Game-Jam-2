class_name PlayerManager
extends Node2D

var PLAYER_SCENE := preload("uid://bdqcutktqtcxw")
var player: Player

signal player_died(player:Player)



func _ready() -> void:
	DI.register("_player_manager", self)
	
	spawn_player()


func spawn_player():
	if is_instance_valid(player): 
		player.queue_free()
	player = PLAYER_SCENE.instantiate()
	player.position = %SpawnMarker2D.global_position
	
	player.died.connect(_on_player_died)
	
	%PlayerContainer.add_child(player)

func get_glue_layer()-> GlueLayer:
	return %GlueLayer

func get_player_position()-> Vector2:
	return player.position if player else Vector2.ZERO



func _on_player_died(player:Player):
	player_died.emit(player)

class_name PlayerManager
extends Node2D

var PLAYER_SCENE := preload("uid://bdqcutktqtcxw")


var player: Player
func _ready() -> void:
	DI.register("_player_manager", self)
	
	spawn_player()


func spawn_player():
	if is_instance_valid(player): 
		player.queue_free()
	player = PLAYER_SCENE.instantiate()
	player.position = %SpawnMarker2D.global_position
	add_child(player)

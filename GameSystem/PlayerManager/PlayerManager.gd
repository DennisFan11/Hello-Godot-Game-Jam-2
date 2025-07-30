class_name PlayerManager
extends Node2D

@export var cursor:Texture2D

var PLAYER_SCENE := preload("uid://bdqcutktqtcxw")
var player: Player

signal player_died(player:Player)



func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)

func _ready() -> void:
	DI.register("_player_manager", self)
	
	if cursor:
		Input.set_custom_mouse_cursor(cursor)
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

func get_player_velocity()-> Vector2:
	return player.velocity if player else Vector2.ZERO

func get_player_rotation()-> float:
	return player.rotation if player else 0.0

func get_mouse_vec():
	var vec = (player.get_global_mouse_position() - player.global_position).normalized()
	if not player.direction:
		vec.x *= -1
	return vec

func _on_player_died(player:Player):
	player_died.emit(player)

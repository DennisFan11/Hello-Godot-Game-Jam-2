@tool
class_name EnemyManager
extends IGameSubManager


@export_category("敵人生成射線")

@export_range(-300, -10, 2)
var HEIGHT: float = -150:
	set(new):
		HEIGHT = new
		_reset_spawnner_ray()

@export_range(10, 200, 2)
var NON_SPAWN_AREA: float = 50: 
	set(new):
		NON_SPAWN_AREA = new
		_reset_spawnner_ray()

@export_range(250, 500, 2)
var WEIGHT: float = 250:
	set(new):
		WEIGHT = new
		_reset_spawnner_ray()

func _reset_spawnner_ray():
	if not %SpawnnerHintLineL: return 
	if not %SpawnnerHintLineR: return 
	
	%SpawnnerHintLineL.points = [
		Vector2(-WEIGHT, HEIGHT),
		Vector2(-NON_SPAWN_AREA, HEIGHT)
	]
	%SpawnnerHintLineR.points = [
		Vector2(NON_SPAWN_AREA, HEIGHT),
		Vector2(WEIGHT, HEIGHT)
	]
	
func _ready() -> void:
	if Engine.is_editor_hint():
		return 
	DI.register("_enemy_manager", self)

var _cooldown_timer := CooldownTimer.new()
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return 
	%PlayerPosMarker2D.position.x = _player_manager.get_player_position().x
	
	if not _cooldown_timer.is_ready():
		return 
	_cooldown_timer.trigger(0.5)
	
	_try_spawn_enemy()
	

var _player_manager: PlayerManager
func _get_random_start_point()-> Vector2:
	var player_posX := _player_manager.get_player_position().x
	if randf_range(0.0, 1.0)>0.5:
		return Vector2 (
			randf_range(-WEIGHT, -NON_SPAWN_AREA) + player_posX,
			HEIGHT
		)
	else:
		return Vector2 (
			randf_range(NON_SPAWN_AREA, WEIGHT) + player_posX,
			HEIGHT
		)

func _get_casted_point()-> Vector2:
	var start_point := _get_random_start_point()
	return Utility.raycast(
		start_point,
		start_point + Vector2(0.0, 1000.0)
	).get("position", Vector2.ZERO)

func _try_spawn_enemy():
	var spawn_pos: Vector2
	
	for i in range(10):
		spawn_pos= _get_casted_point()
		if spawn_pos:
			break
	if not spawn_pos: return 
	_spawn_enemy(spawn_pos)


var ENEMY_A_SCENE := preload("uid://dsivi152md61i")
func _spawn_enemy(spawn_pos: Vector2):
	var enemy = ENEMY_A_SCENE.instantiate()
	enemy.position = spawn_pos
	add_child(enemy)
	




#

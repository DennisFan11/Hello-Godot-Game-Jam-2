class_name EnemyManager
extends IGameSubManager

# 敵人死亡信號
signal enemy_died(enemy: Enemy)

## 生成敵人冷卻
## 當此值<0時不生成敵人
@export var SPWAN_COOLDOWN:float = 0.5

## 最大敵方數量,
## 當此值<=0時不限制敵方數量
@export var MAX_ENEMY_NUMBER: int = 0

## 生成的敵人種類,
## 相同的敵人越多越容易生成,
## 可填空
@export var ENEMY_TYPE: Array[PackedScene] = []

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
	DI.register("_enemy_manager", self)

var _cooldown_timer := CooldownTimer.new()
func _process(delta: float) -> void:
	%PlayerPosMarker2D.position.x = _player_manager.get_player_position().x

	_try_spawn_enemy()


var _player_manager: PlayerManager
func _get_random_start_point() -> Vector2:
	var player_posX := _player_manager.get_player_position().x
	if randf_range(0.0, 1.0) > 0.5:
		return Vector2(
			randf_range(-WEIGHT, -NON_SPAWN_AREA) + player_posX,
			HEIGHT
		)
	else:
		return Vector2(
			randf_range(NON_SPAWN_AREA, WEIGHT) + player_posX,
			HEIGHT
		)

func _get_casted_point() -> Vector2:
	var start_point := _get_random_start_point()
	return Utility.raycast(
		start_point,
		start_point + Vector2(0.0, 1000.0)
	).get("position", Vector2.ZERO)

func _try_spawn_enemy():
	if not _cooldown_timer.is_ready() or SPWAN_COOLDOWN < 0.0:
		return
	_cooldown_timer.trigger(SPWAN_COOLDOWN)

	if not len(ENEMY_TYPE):
		return
	if MAX_ENEMY_NUMBER > 0 \
	and %Enemy.get_child_count() >= MAX_ENEMY_NUMBER:
		return

	for i in range(10):
		var spawn_pos = _get_casted_point()
		if spawn_pos != Vector2.ZERO:
			_spawn_enemy(spawn_pos)
			return


func _spawn_enemy(spawn_pos: Vector2):
	var rng = ENEMY_TYPE.pick_random()
	if rng is PackedScene:
		var enemy = rng.instantiate()
		enemy.position = spawn_pos
		%Enemy.add_child(enemy)

		# 連接敵人的死亡信號到 EnemyManager
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)

		print("spawn enemy: ", enemy)

func _on_enemy_died(enemy: Enemy):
	"""當敵人死亡時觸發此方法"""
	enemy_died.emit(enemy)
	print("Enemy died: ", enemy)


#

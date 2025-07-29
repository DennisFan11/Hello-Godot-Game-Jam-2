class_name EnemyManager
extends IGameSubManager

"""
只負責 Spawn Enemy 
被 WaveManager 和 TestUI 使用
"""
## PUBLIC







# 敵人死亡信號
signal enemy_died(enemy: Enemy)

## 生成的敵人種類,
enum ENEMY_TYPE {A, B, C, D, E}

## 尋找空位生成敵人 (可能失敗)
func spawn_enemy(enemy_type: ENEMY_TYPE)-> Enemy:
	for i in range(10):
		var spawn_pos := _gen_random_position()
		if _has_space(spawn_pos):
			return _spawn_enemy(enemy_type, spawn_pos)
	return null

## 在指定位置強制生成敵人
var _terrain_manager: TerrainManager
func spawn_enemy_force(enemy_type: ENEMY_TYPE, spawn_pos: Vector2)-> Enemy:
	_terrain_manager.clip(
		GeometryShapeTool.gen_circle(50.0, spawn_pos)
	)
	return _spawn_enemy(enemy_type, spawn_pos)






## PRIVATE ///////////////////////////

var _enemy_file: Dictionary[ENEMY_TYPE, PackedScene] = {
	ENEMY_TYPE.A : preload("uid://dsivi152md61i"),
	ENEMY_TYPE.B : preload("uid://cmbx8s22egbna"),
	ENEMY_TYPE.C : preload("uid://bncde2rk1wyly"),
	ENEMY_TYPE.D : preload("uid://4vlqptxodl6n"),
	ENEMY_TYPE.E : preload("uid://1irg6p4f8wkm"),
}

func _ready() -> void:
	DI.register("_enemy_manager", self)














func _spawn_enemy(enemy_type: ENEMY_TYPE, spawn_pos: Vector2)-> Enemy:
	var enemy: Enemy = _enemy_file[enemy_type].instantiate()
	
	enemy.position = spawn_pos
	
	# 連接敵人的死亡信號到 EnemyManager
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	%EnemyContainer.add_child(enemy)
	print("spawn pos:{0} enemy:{1}".format([spawn_pos, enemy]))
	return enemy

func _on_enemy_died(enemy: Enemy):
	"""當敵人死亡時觸發此方法"""
	enemy_died.emit(enemy)
	enemy.died.disconnect(_on_enemy_died)
	#print("Enemy died: ", enemy)






## TOOL ////////////////////////

var _player_manager: PlayerManager
func _gen_random_position()-> Vector2:
	var distance2player: float = randf_range(300.0, 400.0)
	var angle2player:    float = randf_range(0.0, PI*2.0)
	
	var player_pos = _player_manager.get_player_position()
	return player_pos + (Vector2.from_angle(angle2player) * distance2player) 


func _has_space(global_pos: Vector2)-> bool:
	return Utility.collide_query_circle(global_pos, 50.0, 1<<19 || 1<< 0).is_empty()






#

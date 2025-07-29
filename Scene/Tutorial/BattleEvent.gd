@tool
extends DistanceSignal

var _enemy_manager: EnemyManager
func _inside():
	#print("BATTLE EVENT")
	for i in range(5):
		_spawn_enemy()
	

func _spawn_enemy():
	var rand_pos = Vector2( randfn(-10, 10), randfn(-10, 10))
	_enemy_manager.spawn_enemy_force(
		EnemyManager.ENEMY_TYPE.B,
		global_position + rand_pos)

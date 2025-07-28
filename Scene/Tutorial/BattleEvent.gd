@tool
extends DistanceSignal

var _enemy_manager: EnemyManager
func _inside():
	#print("BATTLE EVENT")
	for i in range(3):
		_spawn_enemy()
	

func _spawn_enemy():
	_enemy_manager.spawn_enemy_force(
		EnemyManager.ENEMY_TYPE.B,
		global_position)

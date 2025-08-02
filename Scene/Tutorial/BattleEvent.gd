@tool
extends DistanceSignal

var _enemy_manager: EnemyManager
func _inside():
	#print("BATTLE EVENT")
	for i in range(5):
		_spawn_enemy()
		await get_tree().create_timer(0.1).timeout

func _spawn_enemy():
	var rand_pos = Vector2(randfn(-10, 10), randfn(-10, 10))
	_enemy_manager.spawn_enemy_force(
		_enemy_manager.get_enemy("B"),
		global_position + rand_pos
	)

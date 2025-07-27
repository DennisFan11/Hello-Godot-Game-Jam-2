class_name Player
extends Character

# 升級系統引用（AutoLoad 單例，無需型別宣告）
var upgrade_system

# 信號
signal health_changed(current_health: int, max_health: int)
signal experience_gained(amount: int)



func _ready():
	# 初始化升級系統引用
	upgrade_system = PlayerUpgradeSystem

	# 連接信號
	PlayerUpgradeSystem.stats_updated.connect(_on_stats_updated)
	_update_stats_from_upgrade_system(upgrade_system.player_stats)

func _update_stats_from_upgrade_system(stats):
	max_hp = stats.max_health
	_hp = stats.current_health
	
	attack_damage = stats.attack_damage

	health_changed.emit(_hp, max_hp)

func _on_stats_updated(_stats):
	_update_stats_from_upgrade_system(_stats)



# 獲得經驗值
func gain_experience(amount: int):
	upgrade_system.gain_experience(amount)
	experience_gained.emit(amount)



func health_change(value: int):
	super(value)
	#print("player hp:{0}/{1}".format([_hp, max_hp]))

	upgrade_system.player_stats.set_stats("current_health", _hp)
	upgrade_system._save_player_data()

	health_changed.emit(_hp, max_hp)



func _on_animation_finished(anim_name:String):
	pass

class_name Player
extends Character

# 升級系統引用（AutoLoad 單例，無需型別宣告）
var upgrade_system

# 動態屬性（會被升級系統更新）
var current_max_speed: float = 100.0
var current_jump_speed: float = 270.0

# 信號
signal health_changed(current_health: int, max_health: int)
signal experience_gained(amount: int)



func _ready():
	# 初始化升級系統引用
	upgrade_system = PlayerUpgradeSystem

	# 連接信號
	upgrade_system.stats_updated.connect(_on_stats_updated)
	_update_stats_from_upgrade_system()

func _update_stats_from_upgrade_system():
	var stats = upgrade_system.player_stats

	current_max_speed = stats.move_speed
	current_jump_speed = stats.jump_power

	attack_damage = stats.attack_damage

	max_hp = stats.max_health
	_hp = stats.current_health

	health_changed.emit(_hp, max_hp)

func _on_stats_updated(_stats):
	_update_stats_from_upgrade_system()

# 獲得經驗值
func gain_experience(amount: int):
	upgrade_system.gain_experience(amount)
	experience_gained.emit(amount)



func health_change(value: int):
	super(value)

	upgrade_system.player_stats.current_health = _hp
	upgrade_system._save_player_data()

	health_changed.emit(_hp, max_hp)

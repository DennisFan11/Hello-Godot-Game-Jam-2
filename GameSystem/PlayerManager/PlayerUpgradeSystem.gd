extends Node

# 玩家升級系統 - AutoLoad 單例
# 負責管理玩家屬性升級、等級提升等功能
# 作為 AutoLoad 單例存在，跨場景持續存在

# 玩家數據實例
var player_stats: PlayerStats
var upgrade_levels: UpgradeLevel

var player_stats_save_path = "user://PlayerStats.res"
var upgrade_levels_save_path = "user://UpgradeLevel.res"

# 信號
signal stats_updated(stats: PlayerStats)
signal level_up(new_level: int)
signal upgrade_applied(upgrade_type: String, new_level: int)

func _ready():
	print("PlayerUpgradeSystem (AutoLoad) 正在初始化...")

	init_player_stats()
	
	# 初始化升級等級
	_init_upgrade_levels()
	
	# 載入存檔數據
	# _load_player_data()
	
	print("✓ PlayerUpgradeSystem (AutoLoad) 初始化完成")

func get_stats(stats_name:String) -> Variant:
	return player_stats.get_stats(stats_name)



func init_player_stats(load_data:bool = true):
	if player_stats:
		player_stats.changed.disconnect(_on_stats_updated)

	var path = player_stats_save_path if load_data else ""		
	player_stats = PlayerStats.new(path)
	player_stats.changed.connect(_on_stats_updated)

func _init_upgrade_levels(load_data:bool = true):
	var path = upgrade_levels_save_path if load_data else ""
	upgrade_levels = UpgradeLevel.new(path)



# 獲得經驗值
func gain_experience(amount: int):
	player_stats.add_stats("experience_points", amount)
	_check_level_up()

# 檢查升級
func _check_level_up():
	var required_exp = _get_required_exp_for_level(player_stats.level + 1)
	if get_stats("experience_points") >= required_exp:
		upgrade_levels.add_upgrade_point(1)
		player_stats.add_stats("level", 1)
		level_up.emit(player_stats.level)
		_check_level_up() # 遞歸檢查是否可以連續升級

# 計算升級所需經驗值
func _get_required_exp_for_level(level: int) -> int:
	return level * level * 100 # 指數成長公式

# 應用升級
func apply_upgrade(upgrade_type:String, count:int = 1) -> int:
	# 嘗試升級指定次數到類型
	count = upgrade_levels.try_upgrade(upgrade_type)

	if count > 0:
		# 應用屬性強化
		_apply_stat_upgrade(upgrade_type, count)
		
		# 發送信號
		upgrade_applied.emit(upgrade_type, upgrade_levels.get_level(upgrade_type))
		
		# 保存數據
		_save_player_data()
	
	return count

# 應用屬性強化到玩家數據
func _apply_stat_upgrade(upgrade_type:String, count:int = 1):
	var config = upgrade_levels.get_config(upgrade_type)
	player_stats.add_stats(config.stats, config.base_value * count)

	if config.stats == "max_health":
		player_stats.set_stats("current_health", player_stats.max_health) # 升級時回滿血

# 重置升級點數 (用於測試)
func reset_upgrades():
	var experience_points = player_stats.experience_points

	# 重置升級等級
	_init_upgrade_levels(false)

	# 重置玩家屬性到初始值
	init_player_stats(false)

	# 保留當前等級和經驗值，升級點數根據等級計算
	gain_experience(experience_points)

	# 保存數據
	_save_player_data()



# 保存玩家數據
func _save_player_data():
	player_stats.save_file(player_stats_save_path)
	upgrade_levels.save_file(upgrade_levels_save_path)

func _on_stats_updated():
	stats_updated.emit(player_stats)

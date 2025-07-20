extends Node

# 玩家升級系統 - AutoLoad 單例
# 負責管理玩家屬性升級、等級提升等功能
# 作為 AutoLoad 單例存在，跨場景持續存在

# 玩家數據實例
var player_stats: PlayerStats
var upgrade_levels: UpgradeLevel

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

	if load_data:
		player_stats = ResourceLoader.load("user://PlayerStats.tres")
	if not load_data or not player_stats:
		player_stats = PlayerStats.new()
	player_stats.changed.connect(_on_stats_updated)

	return player_stats

func _init_upgrade_levels(load_data:bool = true):
	if load_data:
		upgrade_levels = ResourceLoader.load("user://UpgradeLevel.tres")
	if not load_data or not upgrade_levels:
		upgrade_levels = UpgradeLevel.new()

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
	ResourceSaver.save(upgrade_levels, "user://UpgradeLevel.tres")
	ResourceSaver.save(player_stats, "user://PlayerStats.tres")

	# var save_data = {
	# 	"player_stats": player_stats.to_dict(),
	# 	"upgrade_levels": upgrade_levels
	# }
	
	# if ConfigRepo and ConfigRepo.repo:
	# 	ConfigRepo.repo.set_value("PlayerUpgrade", "save_data", save_data)
	# 	ConfigRepo.save()
	# else:
	# 	print("警告：ConfigRepo 未準備好，無法保存升級數據")

# 載入玩家數據
# func _load_player_data():
# 	if not ConfigRepo or not ConfigRepo.repo:
# 		print("警告：ConfigRepo 未準備好，使用默認升級數據")
# 		return
	
# 	var save_data = ConfigRepo.repo.get_value("PlayerUpgrade", "save_data", {})
	
# 	# if save_data.has("player_stats"):
# 	# 	player_stats.from_dict(save_data.player_stats)
	
# 	if save_data.has("upgrade_levels"):
# 		upgrade_levels = save_data.upgrade_levels
# 	else:
# 		_init_upgrade_levels()

func _on_stats_updated():
	stats_updated.emit(player_stats)

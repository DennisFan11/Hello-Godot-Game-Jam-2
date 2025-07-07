extends Node

# 玩家升級系統 - AutoLoad 單例
# 負責管理玩家屬性升級、等級提升等功能
# 作為 AutoLoad 單例存在，跨場景持續存在

# 角色屬性數據結構
class PlayerStats:
	var max_health: int = 100
	var current_health: int = 100
	var attack_damage: int = 10
	var move_speed: float = 100.0
	var jump_power: float = 200.0
	var skill_cooldown_reduction: float = 0.0
	var experience_points: int = 0
	var level: int = 1
	var upgrade_points: int = 0
	
	func to_dict() -> Dictionary:
		return {
			"max_health": max_health,
			"current_health": current_health,
			"attack_damage": attack_damage,
			"move_speed": move_speed,
			"jump_power": jump_power,
			"skill_cooldown_reduction": skill_cooldown_reduction,
			"experience_points": experience_points,
			"level": level,
			"upgrade_points": upgrade_points
		}
	
	func from_dict(data: Dictionary):
		max_health = data.get("max_health", 100)
		current_health = data.get("current_health", 100)
		attack_damage = data.get("attack_damage", 10)
		move_speed = data.get("move_speed", 100.0)
		jump_power = data.get("jump_power", 200.0)
		skill_cooldown_reduction = data.get("skill_cooldown_reduction", 0.0)
		experience_points = data.get("experience_points", 0)
		level = data.get("level", 1)
		upgrade_points = data.get("upgrade_points", 0)

# 升級選項枚舉
enum UpgradeType {
	HEALTH,
	ATTACK,
	SPEED,
	JUMP,
	COOLDOWN_REDUCTION
}

# 升級配置
var upgrade_configs = {
	UpgradeType.HEALTH: {
		"name": "生命值強化",
		"description": "增加最大生命值",
		"base_value": 20,
		"max_level": 10,
		"cost": 1
	},
	UpgradeType.ATTACK: {
		"name": "攻擊力強化",
		"description": "增加攻擊傷害",
		"base_value": 5,
		"max_level": 8,
		"cost": 1
	},
	UpgradeType.SPEED: {
		"name": "移動速度強化",
		"description": "增加移動速度",
		"base_value": 15.0,
		"max_level": 6,
		"cost": 1
	},
	UpgradeType.JUMP: {
		"name": "跳躍力強化",
		"description": "增加跳躍高度",
		"base_value": 30.0,
		"max_level": 5,
		"cost": 1
	},
	UpgradeType.COOLDOWN_REDUCTION: {
		"name": "技能冷卻縮減",
		"description": "減少技能冷卻時間",
		"base_value": 0.1,
		"max_level": 5,
		"cost": 2
	}
}

# 玩家數據實例
var player_stats: PlayerStats = PlayerStats.new()
var upgrade_levels: Dictionary = {}

# 信號
signal stats_updated(stats: PlayerStats)
signal level_up(new_level: int)
signal upgrade_applied(upgrade_type: UpgradeType, new_level: int)

func _ready():
	print("PlayerUpgradeSystem (AutoLoad) 正在初始化...")
	
	# 初始化升級等級
	_init_upgrade_levels()
	
	# 載入存檔數據
	_load_player_data()
	
	print("✓ PlayerUpgradeSystem (AutoLoad) 初始化完成")

func _init_upgrade_levels():
	for upgrade_type in UpgradeType.values():
		upgrade_levels[upgrade_type] = 0

# 獲得經驗值
func gain_experience(amount: int):
	player_stats.experience_points += amount
	_check_level_up()
	stats_updated.emit(player_stats)

# 檢查升級
func _check_level_up():
	var required_exp = _get_required_exp_for_level(player_stats.level + 1)
	if player_stats.experience_points >= required_exp:
		player_stats.level += 1
		player_stats.upgrade_points += 1
		level_up.emit(player_stats.level)
		_check_level_up() # 遞歸檢查是否可以連續升級

# 計算升級所需經驗值
func _get_required_exp_for_level(level: int) -> int:
	return level * level * 100 # 指數成長公式

# 應用升級
func apply_upgrade(upgrade_type: UpgradeType) -> bool:
	var config = upgrade_configs[upgrade_type]
	var current_level = upgrade_levels[upgrade_type]
	
	# 檢查是否可以升級
	if current_level >= config.max_level:
		return false
	
	if player_stats.upgrade_points < config.cost:
		return false
	
	# 消耗升級點數
	player_stats.upgrade_points -= config.cost
	upgrade_levels[upgrade_type] += 1
	
	# 應用屬性強化
	_apply_stat_upgrade(upgrade_type, config.base_value)
	
	# 發送信號
	upgrade_applied.emit(upgrade_type, upgrade_levels[upgrade_type])
	stats_updated.emit(player_stats)
	
	# 保存數據
	_save_player_data()
	
	return true

# 檢查是否可以升級
func can_upgrade(upgrade_type: UpgradeType) -> bool:
	"""檢查指定的升級類型是否可以升級"""
	var config = upgrade_configs[upgrade_type]
	var current_level = upgrade_levels[upgrade_type]
	
	# 檢查等級是否達到上限和是否有足夠的升級點數
	return current_level < config.max_level and player_stats.upgrade_points >= config.cost

# 應用屬性強化到玩家數據
func _apply_stat_upgrade(upgrade_type: UpgradeType, value):
	match upgrade_type:
		UpgradeType.HEALTH:
			player_stats.max_health += value
			player_stats.current_health = player_stats.max_health # 升級時回滿血
		UpgradeType.ATTACK:
			player_stats.attack_damage += value
		UpgradeType.SPEED:
			player_stats.move_speed += value
		UpgradeType.JUMP:
			player_stats.jump_power += value
		UpgradeType.COOLDOWN_REDUCTION:
			player_stats.skill_cooldown_reduction += value

# 獲取升級資訊
func get_upgrade_info(upgrade_type: UpgradeType) -> Dictionary:
	var config = upgrade_configs[upgrade_type]
	var current_level = upgrade_levels[upgrade_type]
	
	return {
		"name": config.name,
		"description": config.description,
		"current_level": current_level,
		"max_level": config.max_level,
		"cost": config.cost,
		"can_upgrade": current_level < config.max_level and player_stats.upgrade_points >= config.cost,
		"next_value": config.base_value
	}

# 重置升級點數 (用於測試)
func reset_upgrades():
	# 重置升級等級
	_init_upgrade_levels()
	
	# 重置玩家屬性到初始值
	player_stats.max_health = 100
	player_stats.current_health = 100
	player_stats.attack_damage = 10
	player_stats.move_speed = 100.0
	player_stats.jump_power = 200.0
	player_stats.skill_cooldown_reduction = 0.0
	
	# 保留當前等級和經驗值，升級點數根據等級計算
	player_stats.upgrade_points = player_stats.level - 1 # 只根據等級給予應得的點數
	
	stats_updated.emit(player_stats)

# 保存玩家數據
func _save_player_data():
	var save_data = {
		"player_stats": player_stats.to_dict(),
		"upgrade_levels": upgrade_levels
	}
	
	if ConfigRepo and ConfigRepo.repo:
		ConfigRepo.repo.set_value("PlayerUpgrade", "save_data", save_data)
		ConfigRepo.save()
	else:
		print("警告：ConfigRepo 未準備好，無法保存升級數據")

# 載入玩家數據
func _load_player_data():
	if not ConfigRepo or not ConfigRepo.repo:
		print("警告：ConfigRepo 未準備好，使用默認升級數據")
		return
	
	var save_data = ConfigRepo.repo.get_value("PlayerUpgrade", "save_data", {})
	
	if save_data.has("player_stats"):
		player_stats.from_dict(save_data.player_stats)
	
	if save_data.has("upgrade_levels"):
		upgrade_levels = save_data.upgrade_levels
	else:
		_init_upgrade_levels()

class_name SummaryPanel
extends Control

signal finish()

var _has_opened: bool = false

func _ready() -> void:
	%SummaryButton.pressed.connect(_on_button_click)

func _open() -> void:
	if _has_opened:
		print("SummaryPanel already opened")
		return
	_has_opened = true
	print("SummaryPanel Open")
	visible = true
	# 總擊殺數
	var total_kills = InGameSaveSystem.load_object("total_kills")
	# 武器拼接數
	var weapon_count: int = WeaponManager.get_player_weapon_count()
	# 計算獲得的金幣
	if not total_kills or not weapon_count:
		return 
	var coins: int = _calculate_coins(total_kills, weapon_count)
	%SummaryContext.text = "擊殺敵人數: %d\n武器拼接數: %d\n獲得金幣數: %d" % [total_kills, weapon_count, coins]

	# 累積金幣
	var previous_coins: int = ConfigRepo.repo.get_value("PLAYER_PROPERTIES", "coins", 0)
	var total_coins: int = previous_coins + coins
	ConfigRepo.repo.set_value("PLAYER_PROPERTIES", "coins", total_coins)


func _on_button_click() -> void:
	visible = false
	finish.emit()

# 計算金幣 - 優化版本
func _calculate_coins(kills: int = 0, weapons: int = 0) -> int:
	# 公式: 總擊殺數 / 10 + (武器拼接數 - 1) * 5
	var kill_bonus: int = floori(kills / 10.0)
	var weapon_bonus: int = (weapons - 1) * 5

	return kill_bonus + weapon_bonus

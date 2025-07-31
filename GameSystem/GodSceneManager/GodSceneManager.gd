class_name GodSceneManager
extends CanvasLayer

signal _finished(weapon: Weapon)



func _ready() -> void:
	DI.register("_god_scene_manager", self)
	visible = false

	%GoddessWeaponSelect.set_god_scene_manager(self)


var _game_manager: GameManager

func start_event(args):
	DI.injection(self)
	set_process_mode(PROCESS_MODE_INHERIT)
	_game_manager.stop_game()

	visible = true

	await %GoddessWeaponSelect.start_scene()

func end_event(player_weapon, new_weapon):
	
	DI.injection(self)
	set_process_mode(PROCESS_MODE_PAUSABLE)
	_game_manager.continue_game()
	
	visible = false

	if new_weapon:
		# 印出選擇的武器 ID
		print("GodSceneManager Selected weapon ID:", new_weapon.id)
		CoreManager.start_event("WeaponEditor", [player_weapon, new_weapon])
	else:
		print("GodSceneManager: No weapon selected.")
		WeaponManager.set_player_weapon(player_weapon)
	

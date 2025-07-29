class_name GodSceneManager
extends CanvasLayer

signal _finished(weapon: Weapon)

func _ready() -> void:
	DI.register("_god_scene_manager", self)
	visible = false

	%GoddessWeaponSelect.set_god_scene_manager(self)

func start_event(args):
	LevelManager.pause_scene()

	set_process_mode(PROCESS_MODE_INHERIT)
	var player_weapon = WeaponManager.duplicate_player_weapon()
	visible = true

	await %GoddessWeaponSelect.start_scene(player_weapon)

func end_event(new_weapon):
	visible = false

	if new_weapon:
		var player_weapon = WeaponManager.duplicate_player_weapon()
		# 印出選擇的武器 ID
		print("GodSceneManager Selected weapon ID:", new_weapon.id)
		CoreManager.start_event("WeaponEditor", [player_weapon, new_weapon])
	else:
		# 如果 _weapon_slot.get_current_weapon() 為 null，則返回空陣列
		print("GodSceneManager: No weapon selected.")
		LevelManager.start_game()
	
	set_process_mode(PROCESS_MODE_PAUSABLE)

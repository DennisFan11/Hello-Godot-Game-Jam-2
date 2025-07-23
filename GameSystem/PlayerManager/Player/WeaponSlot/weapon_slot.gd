class_name WeaponSlot
extends Node2D

var first_weapon:Weapon
var total_weight:float = 1.0


func _ready() -> void:
	DI.register("_weapon_slot", self)


## TEST
var _weapon_manager: WeaponManager
var _player_manager: PlayerManager
func _on_injected():
	if not _weapon_manager: return 
	var weapon:Weapon = _weapon_manager.create_weapon_scene(
		_weapon_manager.get_random_weapon_id()
	)
	set_current_weapon(weapon)

func set_current_weapon(weapon: Weapon)-> void:
	if not weapon: return 
	
	if first_weapon:
		first_weapon.queue_free()
	weapon.summoner = _player_manager.player
	first_weapon = weapon
	
	weapon.move_to(%WeaponMarker2D, _player_manager.get_glue_layer(), false)

func take_current_weapon()-> Weapon:
	var curr = first_weapon
	if curr: 
		first_weapon = null
		%WeaponMarker2D.remove_child(curr)
		return curr
	return null

func get_current_weapon()-> Weapon:
	return first_weapon


func start_attack(time: float):
	if first_weapon:
		# 根據主武器播放動畫, 並以所有武器的總重量調整速度
		var anim = first_weapon.ANIM if first_weapon.ANIM else "SwordType"
		var duration = total_weight / time

		%AnimationPlayer.play(anim, -1, duration)
		first_weapon.start_attack()



func _save():
	first_weapon.get_parent().remove_child(first_weapon)
	InGameSaveSystem.save_object("first_weapon", first_weapon)
func _load():
	set_current_weapon(InGameSaveSystem.load_object("first_weapon"))







#func _process(delta: float) -> void:
	#if %AnimationPlayer.is_playing():
		#if first_weapon:
			#first_weapon.frame_attack(delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		%AnimationPlayer.play("RESET")
	first_weapon.end_attack()

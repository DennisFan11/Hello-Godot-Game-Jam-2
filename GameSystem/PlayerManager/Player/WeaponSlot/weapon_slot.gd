class_name WeaponSlot
extends Node2D

var first_weapon:Weapon
var total_weight:float = 1.0


func _ready() -> void:
	DI.register("_weapon_slot", self)


## TEST
var _weapon_manager: WeaponManager
func _on_injected():
	if not _weapon_manager: return 
	var weapon := _weapon_manager.creat_weapon_scene(
			_weapon_manager.get_random_weapon_id())
	set_current_weapon(weapon)

var _global_glue_layer: GlobalGlueLayer
func set_current_weapon(weapon: Weapon)-> void:
	if first_weapon:
		first_weapon.queue_free()
	first_weapon = weapon
	weapon.request_ready()
	weapon.glue_layer = _global_glue_layer
	if weapon.get_parent():
		weapon.reparent(%WeaponMarker2D, false)
	else:
		%WeaponMarker2D.add_child(weapon)

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
		#print(anim)
		%AnimationPlayer.play(anim, -1, total_weight / time)
	else:
		# 加上無法攻擊的提示音? 應該不用
		pass












func _process(delta: float) -> void:
	if %AnimationPlayer.is_playing():
		if first_weapon:
			first_weapon.frame_attack(delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		%AnimationPlayer.play("RESET")

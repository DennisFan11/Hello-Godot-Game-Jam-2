extends Node2D

var first_weapon:Weapon
var total_weight:float = 0.0

func _ready() -> void:
	DI.register("_weapon_slot", self)
	update_weapons()

func update_weapons():
	var weapon_list = $Weapons.get_children()

	# 更新主武器及所有武器的總重量
	first_weapon = null
	total_weight = 0.0

	if len(weapon_list) > 0:
		first_weapon = weapon_list[0]
		for weapon in weapon_list:
			total_weight = weapon.WEIGHT

func start_attack():
	if first_weapon:
		# 根據主武器播放動畫, 並以所有武器的總重量調整速度
		var anim = first_weapon.ANIM if first_weapon.ANIM else "SwordType"
		%AnimationPlayer.play(anim, -1, 1 / total_weight)
	else:
		# 加上無法攻擊的提示音?
		pass

func _process(delta: float) -> void:
	if %AnimationPlayer.is_playing():
		for weapon in $Weapons.get_children():
			weapon.frame_attack(delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		%AnimationPlayer.play("RESET")

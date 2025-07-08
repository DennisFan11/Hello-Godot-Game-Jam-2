extends Node2D

func _ready() -> void:
	DI.register("_weapon_slot", self)
	


func start_attack(time: float):
	%AnimationPlayer.play("SwordType", -1, 1/time)

@export var weapon: Weapon

func _process(delta: float) -> void:
	if %AnimationPlayer.is_playing():
		weapon.frame_attack(delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		%AnimationPlayer.play("RESET")

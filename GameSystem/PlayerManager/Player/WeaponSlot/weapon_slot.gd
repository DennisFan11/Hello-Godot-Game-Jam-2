class_name WeaponSlot
extends Node2D

@export var user:Character

var first_weapon: Weapon
var total_weight: float = 1.0


func _ready() -> void:
	if user is Player:
		DI.register("_weapon_slot", self)


## TEST
func _on_injected():
	var weapon: Weapon = WeaponManager.create_random_weapon()
	set_current_weapon(weapon)

func set_current_weapon(weapon: Weapon) -> void:
	if not weapon: return

	if first_weapon:
		first_weapon.queue_free()

	var w = weapon
	while w:
		w.summoner = user
		w.get_node("%AttackManager").update_attack_type()
		w = w.next_weapon

	weapon.move_to(self, %GlueLayer, false)
	weapon.init_move(self)

	first_weapon = weapon

func take_first_weapon() -> Weapon:
	if first_weapon:
		return first_weapon
	return null

func take_current_weapon() -> Weapon:
	var curr = first_weapon
	if curr:
		first_weapon = null
		remove_child(curr)
		return curr
	return null

func get_current_weapon() -> Weapon:
	return first_weapon


func start_attack(time: float):
	if first_weapon:
		first_weapon.start_move(self, total_weight * time)


func _save():
	first_weapon.get_parent().remove_child(first_weapon)
	InGameSaveSystem.save_object("first_weapon", first_weapon)
func _load():
	set_current_weapon(InGameSaveSystem.load_object("first_weapon"))

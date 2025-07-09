extends Weapon



func frame_attack(delta: float):
	for i:Node2D in %PhysicalComponent.get_weapon_area().get_overlapping_bodies():
		if i is Enemy:
			i.damage(get_damage())

func _ready() -> void:
	%PhysicalComponent.freeze = is_main

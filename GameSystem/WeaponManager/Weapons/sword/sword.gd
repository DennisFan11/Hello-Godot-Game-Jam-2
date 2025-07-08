extends Weapon


const DMG: float = 15


func frame_attack(delta: float):
	for i:Node2D in %WeaponArea.get_overlapping_bodies():
		if i.is_in_group("Enemy"):
			i = i as Enemy
			i.damage(DMG)

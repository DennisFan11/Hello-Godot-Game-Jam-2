extends Weapon

func frame_attack(delta: float):
	for i:Node2D in %WeaponArea.get_overlapping_bodies():
		if i is Enemy:
			i.damage(get_damage())

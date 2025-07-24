







extends Weapon

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_run()


func _run():
	var gds = GDScript.new()
	gds.source_code = %Code.text
	gds.reload()
	if not  gds.can_instantiate():
		return 
	%GDweapon.set_script(gds)
	if %GDweapon.has_method("_attack"):
		%GDweapon._attack()
	
	

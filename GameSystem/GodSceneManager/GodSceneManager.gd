class_name GodSceneManager
extends CanvasLayer


func _ready() -> void:
	DI.register("_god_scene_manager", self)
	visible = false



func start_event()-> Array[Weapon]:
	_shader_manager.enable("frosted_glass")
	visible = true
	_clear_weapon()
	_set_weapon()
	var selected: Weapon = await _finished
	selected = selected
	visible = false
	_shader_manager.disable("frosted_glass")
	_clear_weapon()
	return [selected, _weapon_manager.creat_weapon_scene(_weapon_manager.get_random_weapon_id())] ## FIXME
signal _finished(weapon: Weapon)

var _shader_manager: ShaderManager
var _weapon_manager: WeaponManager
var _weapon_slot:    WeaponSlot

var _weapon_arr: Array[Weapon] = []
func _clear_weapon()-> void:
	for i in _weapon_arr:
		i.queue_free()
	_weapon_arr = []

func _set_weapon()-> void:
	var origin_id = _weapon_slot.get_current_weapon().id
	var left_id: String = _weapon_manager.get_random_weapon_id()
	var right_id: String = _weapon_manager.get_random_weapon_id()
	_set_weapon_scene(%OriginMarker2D, "Main")
	_set_weapon_scene(%RightMarker2D, _weapon_manager.get_random_weapon_id())
	_set_weapon_scene(%LeftMarker2D, _weapon_manager.get_random_weapon_id())
	



## TOOL //////////////
func _set_weapon_scene(marker: Node2D, weapon_id: String):
	
	var weapon: Weapon = (
		_weapon_slot.take_current_weapon()
		if weapon_id=="Main" else
		_weapon_manager.creat_weapon_scene(weapon_id))
	_weapon_arr.append(weapon)
	_set_weapon_node(marker, weapon)

func _set_weapon_node(marker: Node2D, weapon: Weapon):
	weapon.move_to(marker, %GlueLayer, false)
	
	for i in weapon.get_all_weapon():
		i.on_click.connect(
			func (weapon: Weapon):
				weapon = weapon.get_front_weapon()
				_weapon_arr.erase(weapon)
				_finished.emit(weapon))

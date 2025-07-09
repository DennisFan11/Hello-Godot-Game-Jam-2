class_name GodSceneManager
extends CanvasLayer


func _ready() -> void:
	DI.register("_god_scene_manager", self)
	visible = false



func start_event():
	_shader_manager.enable("frosted_glass")
	visible = true
	_clear_weapon()
	_set_weapon()
	await _finished
	visible = false
	_shader_manager.disable("frosted_glass")
signal _finished

var _shader_manager: ShaderManager
var _weapon_manager: WeaponManager
var _weapon_slot:    WeaponSlot

func _clear_weapon()-> void:
	for i in %OriginMarker2D.get_children():
		i.queue_free()
	for i in %RightMarker2D.get_children():
		i.queue_free()
	for i in %LeftMarker2D.get_children():
		i.queue_free()

func _set_weapon()-> void:
	var origin_id = _weapon_slot.get_current_weapon().id
	var left_id: String = _weapon_manager.get_random_weapon_id()
	var right_id: String = _weapon_manager.get_random_weapon_id()
	_set_weapon_scene(%OriginMarker2D, _weapon_slot.get_current_weapon().id)
	_set_weapon_scene(%RightMarker2D, _weapon_manager.get_random_weapon_id())
	_set_weapon_scene(%LeftMarker2D, _weapon_manager.get_random_weapon_id())




## TOOL //////////////
func _set_weapon_scene(marker: Node2D, weapon_id: String):
	var weapon: Weapon = _weapon_manager.creat_weapon_scene(weapon_id)
	weapon.scale = Vector2.ONE * 7.0
	marker.add_child(weapon)
	weapon.on_click.connect(
		func(id: String):
			_finished.emit()
	)
	
	
	
	
	
	

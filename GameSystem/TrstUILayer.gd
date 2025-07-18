extends CanvasLayer


var _god_scene_manager: GodSceneManager
var _weapon_editor: WeaponEditor
func _on_god_event_button_pressed() -> void:
	_god_scene_manager.start_scene_requested.emit()
	var weapon_arr: Array[Weapon] = await _god_scene_manager.start_event()
	await _weapon_editor.start_event(weapon_arr[0], weapon_arr[1])

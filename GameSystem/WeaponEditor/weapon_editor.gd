class_name WeaponEditor
extends CanvasLayer

func _ready() -> void:
	DI.register("_weapon_editor", self)
	visible = false

var _shader_manager: ShaderManager

var _base_weapon: Weapon
var _new_weapon: Weapon

func start_event(base_weapon: Weapon, new_weapon: Weapon=null):
	_base_weapon = base_weapon
	_new_weapon = new_weapon
	
	_shader_manager.enable("frosted_glass")
	visible = true
	
	base_weapon.is_main = true
	base_weapon.move_to(%BaseWeaponMarker, %GlueLayer, false)
	
	if new_weapon:
		#new_weapon.is_main = false
		%FinishButton.disabled = true
		new_weapon.move_to(%SelectedMarker, %GlueLayer)
	
	await _finished
	visible = false
	_shader_manager.disable("frosted_glass")

signal _finished

func _process(delta: float) -> void:
	%SelectedMarker.position = %SelectedMarker.get_global_mouse_position()

func _unhandled_input(event: InputEvent):
	if event is InputEventPanGesture:
		%SelectedMarker.rotation -= 2.0 * event.delta.x * get_process_delta_time()
	if event.is_action_pressed("left_click"):
		try_merge()





func try_merge():
	if (not _base_weapon or not _new_weapon):
		return
	
	if _new_weapon.is_collide():
		print("[WEAPON_EDITOR] is collied")
		return
	
	if not _new_weapon.is_glued():
		print("[WEAPON_EDITOR] is not glued")
		return
	
	merge()

var _global_glue_layer: GlobalGlueLayer
func merge():
	print("[WEAPON_EDITOR] merged")
	
	## 指向最後一個武器
	var back_weapon: Weapon = _base_weapon
	while back_weapon.next_weapon:
		back_weapon = back_weapon.next_weapon
	_new_weapon.request_ready()
	back_weapon.set_next_weapon(_new_weapon)
	_new_weapon = null
	%FinishButton.disabled = false
	
	




#

var _weapon_slot: WeaponSlot
func _on_finish_button_pressed() -> void:
	if _new_weapon:
		%FinishButton.disabled = false
	_base_weapon.request_ready()
	_weapon_slot.set_current_weapon(_base_weapon)
	_base_weapon = null
	_finished.emit()
	print("[WEAPON EDITOR] weapon edit finish")

	

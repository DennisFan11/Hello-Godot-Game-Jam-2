class_name WeaponEditor
extends Node2D

func _ready() -> void:
	DI.register("_weapon_editor", self)
	visible = false
	%CanvasLayer.visible = false

var _shader_manager: ShaderManager

var _base_weapon: Weapon
var _new_weapon: Weapon

func start_event(base_weapon: Weapon, new_weapon: Weapon=null):
	_base_weapon = base_weapon
	_new_weapon = new_weapon
	
	_shader_manager.enable("frosted_glass")
	visible = true
	%CanvasLayer.visible = true
	
	base_weapon.is_main = true
	base_weapon.move_to(%BaseWeaponMarker, %GlueLayer, false)
	
	if new_weapon:
		#new_weapon.is_main = false
		%FinishButton.disabled = true
		new_weapon.move_to(%SelectedMarker, %GlueLayer)
	
	_rebind_weapon_event()
	await _finished
	visible = false
	%CanvasLayer.visible = false

	_shader_manager.disable("frosted_glass")

signal _finished

var _player_manager: PlayerManager
func _process(delta: float) -> void:
	%SelectedMarker.position = %SelectedMarker.get_global_mouse_position()
	%BaseWeaponMarker.global_position = _player_manager.get_player_position()
	_weapon_shader_update()

func _unhandled_input(event: InputEvent):
	if event is InputEventPanGesture:
		%SelectedMarker.rotation -= 2.0 * event.delta.x * get_process_delta_time()
	if event.is_action_pressed("left_click"):
		try_merge()




func _weapon_shader_update():
	if _new_weapon:
		if not _new_weapon.is_collide():
			_new_weapon.is_glued()

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

func merge():
	print("[WEAPON_EDITOR] merged")
	
	select_cooldown.trigger(0.5)
	
	## 指向最後一個武器
	_base_weapon.get_back_weapon().set_next_weapon(_new_weapon)
	_new_weapon = null
	%FinishButton.disabled = false
	
	_rebind_weapon_event()
	
	




#

var _weapon_slot: WeaponSlot
func _on_finish_button_pressed() -> void:
	if _new_weapon:
		%FinishButton.disabled = false
	_weapon_slot.set_current_weapon(_base_weapon)
	_base_weapon = null
	_finished.emit()
	print("[WEAPON EDITOR] weapon edit finish")

var select_cooldown: CooldownTimer = CooldownTimer.new()
func _on_selected_weapon(selected_weapon: Weapon):
	if not select_cooldown.is_ready():
		return
	print("[WEAPON EDITOR] weapon selected ")
	if _new_weapon: return 
	if not _base_weapon: return
	if _base_weapon == selected_weapon: return
	
	_new_weapon = selected_weapon
	_new_weapon.get_parent_weapon().next_weapon = null
	%FinishButton.disabled = true
	_new_weapon.move_to(%SelectedMarker, %GlueLayer)

func _rebind_weapon_event()-> void:
	if _new_weapon:
		for i: Weapon in _new_weapon.get_all_weapon():
			for j in i.on_click.get_connections():
				i.on_click.disconnect(j)
	if _base_weapon:
		for i: Weapon in _base_weapon.get_all_weapon():
			if not i.on_click.is_connected(_on_selected_weapon):
				i.on_click.connect(_on_selected_weapon)

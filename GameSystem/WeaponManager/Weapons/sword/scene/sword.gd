extends Weapon



func frame_attack(delta: float):
	for i:Node2D in %PhysicalComponent.get_weapon_area().get_overlapping_bodies():
		if i is Enemy:
			i.damage(get_damage())

func _ready() -> void:
	%PhysicalComponent.freeze = is_main


func _on_physical_component_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("left_click"):
		on_click.emit(id)




var _message_box_manager: MessageBoxManager


var _message_box: MessageBox
func _process(delta: float) -> void:
	if _message_box:
		_message_box.global_position = _message_box_manager.get_global_mouse_position()

func _on_physical_component_mouse_entered() -> void:
	if not _message_box:
		_message_box = _message_box_manager.create_message_box()
		_message_box.set_string(get_weapon_name())


func _on_physical_component_mouse_exited() -> void:
	if _message_box:
		_message_box.queue_free()
		_message_box = null

func _exit_tree() -> void:
	if _message_box:
		_message_box.queue_free()

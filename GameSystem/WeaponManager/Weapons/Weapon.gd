class_name Weapon
extends Derivative

var id: String = "sword"

## 武器傷害
@export var DMG: float = 15.0
## 
#@export var SPEED: float = 0.2
## 武器重量
@export var WEIGHT: float = 1.0
## 武器使用動畫
@export var ANIM: String = "SwordType"

@export var NAME: String = ""



var is_main: bool = true
var next_weapon: Weapon
var glue_layer: Node2D:
	set(new):
		glue_layer = new
		request_ready()
		if next_weapon:
			next_weapon.glue_layer = new

func get_weapon_name()-> String:
	var str = ""
	var curr_weapon: Weapon = self
	while curr_weapon.next_weapon:
		curr_weapon = curr_weapon.next_weapon
		str += "[" + curr_weapon.NAME + "]"
	return str + NAME

func get_damage()-> int:
	var damage = DMG
	if summoner and summoner.has_method("get_damage"):
		damage += summoner.get_damage()
	return damage

## 轉移武器
func move_to(target_node: Node, glue_layer: GlueLayer, keep_global_transform: bool = true):
	self.glue_layer = glue_layer
	request_ready()
	if not keep_global_transform:
		self.position = Vector2.ZERO
		self.rotation = 0.0
	if get_parent():
		reparent(target_node, keep_global_transform)
	else:
		target_node.add_child(self)
	


# used by player
#func frame_attack(delta: float)-> void:
	#for i in _physical_components:
		#for j:Node2D in i.get_attack_area().get_overlapping_bodies():
			#if j is Enemy:
				#j.take_damage(get_damage())
	#if next_weapon: next_weapon.frame_attack(delta)

func init_move(weapon_slot):
	var move = %MoveManager.get_enable_action()
	if move:
		move[0].init_move(weapon_slot)
		return true
	return false

func start_move(weapon_slot, time):
	var move = %MoveManager.get_enable_action()
	if move:
		move[0].start_move(weapon_slot, time)
		return true
	return false

func start_attack():
	%AttackManager.enable_action(true)
	if next_weapon: next_weapon.start_attack()

func end_attack():
	%AttackManager.enable_action(false)
	if next_weapon: next_weapon.end_attack()

# used by GodSceneManager
signal on_click(weapon: Weapon)

















# used by WeaponEditor
func get_parent_weapon()-> Node2D:
	return $"../.."

func get_front_weapon()-> Weapon:
	var front_weapon: Weapon = self
	while front_weapon.get_parent_weapon() is Weapon:
		front_weapon = front_weapon.get_parent_weapon()
	return front_weapon

func get_back_weapon()-> Weapon:
	var back_weapon: Weapon = self
	while back_weapon.next_weapon:
		back_weapon = back_weapon.next_weapon
	return back_weapon

func set_next_weapon(weapon: Weapon)-> void:
	weapon.summoner = self.summoner

	next_weapon = weapon
	weapon.move_to(%NextWeaponContainer, glue_layer)


## 和其他武器重疊
func is_collide()-> bool:
	for i in _physical_components:
		if i.is_collide(): return true
	if next_weapon:
		return next_weapon.is_collide()
	return false

## 和其他武器相黏
func is_glued()-> bool:
	for i in _physical_components:
		if i.is_glued(): return true
	return false

func get_all_weapon()-> Array[Weapon]:
	var arr: Array[Weapon] = []
	var curr: Weapon = self
	arr.append(curr)
	while curr.next_weapon:
		curr = curr.next_weapon
		arr.append(curr)
	return arr

var _message_box_manager: MessageBoxManager

















## ////////// PRIVATE \\\\\\\\\\


var _physical_components: Array[PhysicalComponent] = []

func _ready() -> void:
	for child: Node in get_children():
		if child is PhysicalComponent:
			_add_physical_components(child)

var _message_box: MessageBox
func _add_physical_components(child: PhysicalComponent):
	_physical_components.append(child)
	child.freeze = is_main
	child._set_metaball()
	child.input_event.connect(
		func(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		if event.is_action_pressed("left_click"):
			on_click.emit(self)
	)
	child.mouse_entered.connect(
		func ():
			if not _message_box:
				_message_box = _message_box_manager.create_message_box()
				_message_box.set_string(get_weapon_name())
	)
	child.mouse_exited.connect(
		func():
			if _message_box:
				_message_box.queue_free()
				_message_box = null
	)

func _process(delta: float) -> void:
	if _message_box:
		_message_box.global_position = _message_box_manager.get_global_mouse_position()

func _exit_tree() -> void:
	if _message_box: _message_box.queue_free()
























#

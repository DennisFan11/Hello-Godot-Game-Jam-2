extends CanvasLayer

var inventory_system: Node
var weapon_list: ItemList
var weapon_icon: TextureRect
var weapon_name: Label
var stats_container: VBoxContainer
var inventory_visible: bool = false

func _ready() -> void:
	DI.register("_inventory_uI", self)
	$UI/Background.hide()
	await setup_references()
	setup_input()
	connect_signals()

func setup_references() -> void:
	inventory_system = PlayerInventorySystem
	await ready
	
	weapon_list = find_child("WeaponItemList")
	if not weapon_list:
		push_error("無法找到武器列表節點")
		return
		
	weapon_icon = find_child("WeaponIcon")
	weapon_name = find_child("WeaponName")
	stats_container = find_child("StatsContainer")
	
	if not weapon_icon or not weapon_name or not stats_container:
		push_error("無法找到必要的UI節點")

func setup_input() -> void:
	pass

func connect_signals() -> void:
	if weapon_list:
		weapon_list.item_selected.connect(_on_weapon_selected)
	if inventory_system:
		inventory_system.weapon_added.connect(_on_weapon_added)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		toggle_inventory()
		get_viewport().set_input_as_handled()

func toggle_inventory() -> void:
	inventory_visible = !inventory_visible
	
	var background = $UI/Background
	if not background:
		push_error("找不到Background節點")
		return
	
	if inventory_visible:
		background.show()
		refresh_weapon_list()
	else:
		background.hide()

func refresh_weapon_list() -> void:
	weapon_list.clear()
	var weapons = inventory_system.get_weapons()
	for weapon in weapons:
		weapon_list.add_item(weapon.name)

func _on_weapon_selected(index: int) -> void:
	var weapons = inventory_system.get_weapons()
	if index >= 0 and index < weapons.size():
		var weapon = weapons[index]
		update_weapon_info(weapon)

func update_weapon_info(weapon) -> void:
	weapon_name.text = weapon.name
	
	# Clear previous stats
	for child in stats_container.get_children():
		child.queue_free()
	
	# Add new stats
	for stat_name in weapon.stats:
		var stat_value = weapon.stats[stat_name]
		var stat_label = Label.new()
		stat_label.text = "%s: %s" % [stat_name, stat_value]
		stats_container.add_child(stat_label)

func _on_weapon_added(_weapon) -> void:
	if inventory_visible:
		refresh_weapon_list()

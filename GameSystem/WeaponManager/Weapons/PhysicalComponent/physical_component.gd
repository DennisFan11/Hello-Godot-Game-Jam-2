@tool
class_name PhysicalComponent
extends RigidBody2D

@export var texture: Texture2D:
	set(new):
		texture = new
		_reset()




const RESIZE: Vector2  = Vector2(32, 32)
const EXPAND_SIZE: int = 2

func _reset()-> void:
	if not is_node_ready():
		return
	var image := texture.get_image()
	image.resize(RESIZE.x, RESIZE.y)
	
	_weapon_polygon = _get_polygon(image)
	_glue_polygon = _expand_polygon(_get_polygon(image), EXPAND_SIZE)
	
	_sprite = ImageTexture.create_from_image(image)
	var _sdf_img = SDF_process.img2SDF(image)
	_sdf_texture = ImageTexture.create_from_image(_sdf_img)



@export_category("自動更新項")
@export var _weapon_polygon:  PackedVector2Array:
	set(new): 
		%AttackCollision.polygon = new
		%RigidCollision.polygon = new
@export var _glue_polygon:    PackedVector2Array:
	set(new): 
		%GlueCollision.polygon = new
@export var _sprite:          Texture2D:
	set(new):
		%Sprite2D.texture = new
@export var _sdf_texture: Texture2D:
	set(new):
		%SDF_Test.texture = new

##  /////////////////////    TOOLS
func _get_polygon(image: Image)-> PackedVector2Array:
	var weapon_bitmask := BitMap.new()
	weapon_bitmask.create_from_image_alpha(image)
	
	var polygons := weapon_bitmask.opaque_to_polygons(
		Rect2(Vector2(), weapon_bitmask.get_size()), 2)
	
	
	var offset = image.get_size()/2.0
	var fixed_polygon: PackedVector2Array = []
	for i in polygons[0]:
		fixed_polygon.append(i - offset)
	return fixed_polygon

func _expand_polygon(polygon: PackedVector2Array, mount: float) -> PackedVector2Array:
	return Geometry2D.offset_polygon(polygon, mount)[0]

func _valid_check()-> bool:
	return _weapon_polygon and \
		_glue_polygon and \
		%Sprite2D.texture and \
		%SDF_Test.texture


var metaball_node: Node2D
func _set_metaball():
	var node: Sprite2D = %SDF_Test.duplicate()
	if not get_parent().glue_layer:
		return
	get_parent().glue_layer.add_child(node)
	node.visible = true
	
	tree_exited.connect(node.queue_free)
	metaball_node = node
	
func _process(delta: float) -> void:
	if not metaball_node: return 
	metaball_node.position = global_position
	metaball_node.scale = global_scale
	metaball_node.rotation = global_rotation


func _ready() -> void:
	if not _valid_check():
		_reset()
	

func get_attack_area()-> Area2D:
	return %AttackArea

## 和其他武器重疊
func is_collide()-> bool:
	for i: Node2D in get_attack_area().get_overlapping_bodies():
		if i == self:
			continue
		if i.is_in_group("PhysicalComponent"):
			_set_state("[color=red]is collide")
			return true
	_set_state("[color=green]is not collide")
	return false

func is_glued()-> bool:
	for i in %GlueArea.get_overlapping_areas():
		if i.is_in_group("Glue"):
			_set_state("[color=green]is glued")
			return true
	_set_state("[color=red]is not glued")
	return false



func _set_state(s: String):
	%StateLabel.text = s





#

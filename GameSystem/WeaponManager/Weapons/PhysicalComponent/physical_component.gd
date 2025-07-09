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
	var image := texture.get_image()
	image.resize(RESIZE.x, RESIZE.y)
	
	_weapon_polygon = _get_polygon(image)
	_glue_polygon = _expand_polygon(_get_polygon(image), EXPAND_SIZE)
	
	_sprite = ImageTexture.create_from_image(image)




@export_category("自動更新項")
@export var _weapon_polygon:  PackedVector2Array:
	set(new): 
		%WeaponCollision.polygon = new
		%MetaBallLine.points = new
		%RigidCollision.polygon = new
@export var _glue_polygon:    PackedVector2Array:
	set(new): 
		%GlueCollision.polygon = new
		
@export var _sprite:          Texture2D:
	set(new):
		%Sprite2D.texture = new

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
		%MetaBallSprite2D.texture




func _ready() -> void:
	if not _valid_check():
		_reset()

func get_weapon_area()-> Area2D:
	return %WeaponArea

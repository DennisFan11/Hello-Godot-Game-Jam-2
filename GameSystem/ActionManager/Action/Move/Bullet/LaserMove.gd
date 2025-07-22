class_name LaserMove
extends BulletMove

@export var width:int = 500
@export var height:int = 50

@export var time:Array[float] = [3, 0.5, 0.5, 5, 1]

@export var aim_line_color:Color = Color.RED

enum ANIM_TYPE {
	AIM,
	PREPARE,
	FIRE,
	ATTACK,
	RETRACT
}
var anim_state:ANIM_TYPE = -1

var timer:float = 0.0

@onready var aim_line = %AimLine
@onready var laser_line = %LaserLine
@onready var collision = %CollisionShape2D
@onready var raycast = %RayCast2D

var _terrain_manager: TerrainManager

func _physics_process(delta):
	pass

func _ready() -> void:
	aim_line.texture.width = width
	aim_line.texture.height = 1
	aim_line.position = Vector2(width / 2, 0)
	aim_line.modulate = aim_line_color
	aim_line.visible = true

	laser_line.texture.width = width
	laser_line.texture.height = height
	laser_line.position = Vector2(0, 0)
	laser_line.scale = Vector2(0, 1)
	laser_line.modulate = Color.WHITE
	laser_line.visible = false

	collision.shape.size = Vector2(width, height)
	collision.position = Vector2(0, 0)
	collision.scale = Vector2(0, 1)
	collision.disabled = true
	
	raycast.target_position = Vector2(width, 0)
	
	play_anim()

func play_anim():
	anim_state += 1

	match anim_state:
		ANIM_TYPE.AIM:
			var tween:Tween = get_tree().create_tween()
			tween.tween_method(aim_tween, 0.0, 1.0, time[anim_state])
			tween.tween_callback(play_anim)
		ANIM_TYPE.FIRE:
			laser_line.visible = true
			collision.disabled = false
			var tween:Tween = get_tree().create_tween()
			tween.tween_method(fire_tween, 0.0, 1.0, time[anim_state])
			tween.tween_callback(play_anim)
		ANIM_TYPE.RETRACT:
			var tween:Tween = get_tree().create_tween()
			tween.tween_method(retract_tween, 1.0, 0.0, time[anim_state])
			tween.tween_callback(play_anim)
		ANIM_TYPE.PREPARE, ANIM_TYPE.ATTACK:
			await get_tree().create_timer(time[anim_state]).timeout
			play_anim()
		_:
			target.queue_free()



func aim_tween(t):
	aim_line.modulate = lerp(aim_line_color, Color(0,0,0,0), t)

	target.position = target.summoner.position
	target.rotation = _get_move_vec().angle()

func fire_tween(t):
	laser_line.position.x = width / 2 * t
	laser_line.scale.x = t

	collision.position.x = width / 2 * t
	collision.scale.x = t
	if raycast.is_colliding():
		var pos = raycast.get_collision_point()
		var circle = GeometryShapeTool.gen_circle(height/2.0, pos)
		_terrain_manager.clip_after(circle)
func retract_tween(t):
	laser_line.scale.y = t
	collision.scale.y = t

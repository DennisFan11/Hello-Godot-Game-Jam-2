class_name Character
extends CharacterBody2D

signal died(character:Character)

## 最大血量
@export var max_hp: int = 30
## 攻擊傷害
@export var attack_damage: int = 0

## 受擊間隔
@export var overbody_time:float = 0.333
## 受擊顏色
@export var overbody_color:Color = Color(5, 0, 0, 10)

var anim_tree:AnimationTree

var _hp: int

## 面朝方向
## false:左 true:右
var direction = true



func _ready() -> void:
	_hp = max_hp

	anim_tree = %AnimationTree
	if anim_tree:
		anim_tree.animation_finished.connect(_on_animation_finished)

func _process(_delta: float) -> void:
	if _overbody.is_ready() or _hp <= 0:
		modulate = Color.WHITE 
	else:
		modulate = overbody_color


func health_change(value: int):
	_hp = clampi(_hp + value, 0, max_hp)

# 回復生命值
func heal(value: int):
	health_change(value)

# 受到傷害
var _particle_manager: ParticleManager
var _overbody: CooldownTimer = CooldownTimer.new()

func take_damage(value: int, from: Node2D) -> bool:
	if not _overbody.is_ready() or value <= 0:
		return false
	_overbody.trigger(overbody_time)

	_particle_manager.create("Blood", global_position) \
		.rotation = (global_position - from.global_position).angle()

	health_change(-value)

	if _hp == 0:
		dead()
	return true

func dead():
	set_anim_state("dead", true)
	died.emit(self)



func get_damage():
	return attack_damage



func set_anim_state(key:String, value:bool = false):
	if not anim_tree:
		return

	if not key:
		printerr()
		return

	anim_tree.set("parameters/conditions/" + key, value)



func _on_animation_finished(anim_name:String):
	if anim_name == "dead":
		queue_free()

class_name Character
extends CharacterBody2D

signal died(character:Character)

@export var max_hp: int = 30
@export var attack_damage: int = 0

@onready var anim_tree:AnimationTree = %AnimationTree

var _hp: int = 30

## 面朝方向
## false:左 true:右
var direction = true



func _ready() -> void:
	if anim_tree:
		anim_tree.animation_finished.connect(_on_animation_finished)

func health_change(value: int):
	_hp = clampi(_hp + value, 0, max_hp)

# 回復生命值
func heal(value: int):
	health_change(value)

# 受到傷害
func take_damage(value: int):
	health_change(-value)

	if _hp == 0:
		dead()

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

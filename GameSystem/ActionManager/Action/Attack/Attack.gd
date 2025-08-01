class_name Attack
extends Action


## 攻擊力
@export var damage: int = 1

var current_damage:int

var attack_type:String = ""

var attack_cooldown_dict = {}

func _physics_process(delta: float) -> void:
	if enable and _cooldown_timer.is_ready():
		update_current_damage()
		try_attack(delta)



func try_attack(_delta):
	pass

func attack(t):
	if current_damage > 0:
		t.take_damage(current_damage, target)

	if cooldown < 0.0: # 當<0時將在擊中後刪除, 主要用於投射物(箭)
		target.queue_free()



func update_current_damage():
	current_damage = damage
	if target and target.has_method("get_damage"):
		current_damage += target.get_damage()
	return current_damage

func set_target(t: Node2D):
	var old_target = target
	
	# 若target為衍生物(子彈/武器)時連接信號
	if super(t):
		if old_target is Derivative:
			old_target.summoner_changed.disconnect(_on_summoner_changed)
		if target is Derivative:
			target.summoner_changed.connect(_on_summoner_changed)

	update_attack_type()

func update_attack_type():
	attack_type = ""
	if target:
		if target is Player \
		or (target is Derivative and target.summoner is Player):
			attack_type = "Enemy"
		elif target is Enemy \
		or (target is Derivative and target.summoner is Enemy):
			attack_type = "Player"
	printt("UAT", self, target, attack_type)



func _on_summoner_changed(summoner):
	update_attack_type()

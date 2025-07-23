class_name Attack
extends Action


## 攻擊力
@export var damage: float = 1.0

var attack_type:String = ""

var attack_cooldown_dict = {}

func _physics_process(delta: float) -> void:
	if enable and _cooldown_timer.is_ready():
		try_attack(delta)

func try_attack(_delta):
	pass

func attack(t):
	if not t in attack_cooldown_dict.keys() \
	or attack_cooldown_dict[t].is_ready():
		t.take_damage(damage)

		var new_cooldown_timer = CooldownTimer.new()
		new_cooldown_timer.trigger(cooldown)
		attack_cooldown_dict[t] = new_cooldown_timer

	#if cooldown > 0.0:
		#_cooldown_timer.trigger(cooldown)
	if cooldown < 0.0: # 當<0時將在擊中後刪除, 主要用於投射物(箭)
		target.queue_free()

func set_target(t: Node2D):
	var old_target = target
	
	# 若target為衍生物(子彈/武器)時連接信號
	if super(t):
		if old_target is Derivative:
			old_target.summoner_changed.disconnect(update_attack_type)
		if target is Derivative:
			target.summoner_changed.connect(update_attack_type)

	update_attack_type()

func update_attack_type():
	if target is Player \
	or (target is Derivative and target.summoner is Player):
		attack_type = "Enemy"
	elif target is Enemy \
	or (target is Derivative and target.summoner is Enemy):
		attack_type = "Player"
	else:
		attack_type = ""

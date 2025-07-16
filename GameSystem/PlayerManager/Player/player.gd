class_name Player
extends CharacterBody2D

# 升級系統引用（AutoLoad 單例，無需型別宣告）
var upgrade_system

# 動態屬性（會被升級系統更新）
var current_max_speed: float = 100.0
var current_jump_speed: float = 270.0
var current_health: int = 100
var current_max_health: int = 100

# 攻擊相關
var attack_damage: int = 10
var attack_cooldown: CooldownTimer = CooldownTimer.new()

## 面朝方向
## false: 左 true:右
var direction = true

# 信號
signal health_changed(current_health: int, max_health: int)
signal player_died()
signal experience_gained(amount: int)

func _ready():
	# 初始化升級系統引用
	upgrade_system = PlayerUpgradeSystem

	# 連接信號
	upgrade_system.stats_updated.connect(_on_stats_updated)
	_update_stats_from_upgrade_system()

func _update_stats_from_upgrade_system():
	var stats = upgrade_system.player_stats
	current_max_speed = stats.move_speed
	current_jump_speed = stats.jump_power
	current_health = stats.current_health
	current_max_health = stats.max_health
	attack_damage = stats.attack_damage

	health_changed.emit(current_health, current_max_health)

func _on_stats_updated(_stats):
	_update_stats_from_upgrade_system()

func health_change(value: int):
	current_health = clampi(
		current_health + value,
		0, current_max_health
	)

	upgrade_system.player_stats.current_health = current_health
	upgrade_system._save_player_data()

	health_changed.emit(current_health, current_max_health)

# 受到傷害
func take_damage(damage: int):
	health_change(-damage)

	print("hp-", damage)

	if current_health <= 0:
		player_died.emit()

# 回復生命值
func heal(amount: int):
	health_change(amount)

# 獲得經驗值
func gain_experience(amount: int):
	upgrade_system.gain_experience(amount)
	experience_gained.emit(amount)

# 攻擊
func attack() -> bool:
	if attack_cooldown.is_ready():
		var cooldown_reduction = upgrade_system.player_stats.skill_cooldown_reduction

		var actual_cooldown = max(0.1, 1.0 - cooldown_reduction)
		attack_cooldown.trigger(actual_cooldown)

		# 這裡可以添加攻擊邏輯 TODO
		%WeaponSlot.start_attack(0.2)

		#print("攻擊！傷害：",  attack_damage)
		return true
	return false

func _physics_process(delta: float) -> void:
	_state_behavior(delta)

	# 攻擊輸入
	if Input.is_action_just_pressed("attack"):
		attack()

# =========================== Player Move ==========================

# 移除常量，使用動態屬性
const INCREASE := 7.0
const DECREASE := 20.0

const GRAVITY := 1000.0 # 重力常量

enum {IDLE, ON_WALL}

var state: int

func _state_behavior(delta: float) -> void:
	match state:
		IDLE:
			# 施加重力
			velocity.y += GRAVITY * delta

			# 处理左右移动 - 使用動態速度
			var vec = Input.get_vector("left", "right", "up", "down")
			if vec.x != 0:
				velocity.x = lerp(velocity.x, current_max_speed * vec.x, INCREASE * delta)
			else: # 停止移动
				velocity.x = lerp(velocity.x, 0.0, DECREASE * delta)

			# 处理跳跃 - 使用動態跳躍力
			if Input.is_action_just_pressed("space") and is_on_floor():
				velocity.y = - current_jump_speed
			if not is_on_floor() and \
				velocity.y > 0.0 and \
				(_climb_R() or _climb_L()) and \
				Input.is_action_pressed("shift"):
				state = ON_WALL
		ON_WALL:
			# 牆壁吸附力
			velocity.x = (1.0 if _climb_R() else -1.0) * 50.0

			# 上下移動
			var vec = Input.get_vector("left", "right", "up", "down")
			if vec.y != 0:
				velocity.y = lerp(velocity.y, current_max_speed * vec.y, INCREASE * delta)
			else:
				velocity.y = lerp(velocity.y, 0.0, DECREASE * delta)

			# 離開牆壁
			if (!_climb_R() and !_climb_L()) or \
				!Input.is_action_pressed("shift"):
				state = IDLE

			# 蹬牆跳
			if Input.is_action_just_pressed("space"):
				velocity.x = current_max_speed * 1.25 * (1 if velocity.x < 0.0 else -1)
				velocity.y = - current_jump_speed
				state = IDLE

	# 轉向
	change_direction()

	move_and_slide()

## 若正在移動, 更改面朝方向
func change_direction():
	if velocity.x == 0.0:
		return

	var new_direction = velocity.x > 0.0
	if state == ON_WALL:
		new_direction = not new_direction

	if new_direction == direction:
		return

	%Body.scale.x = 1 if new_direction else -1
	direction = new_direction
	#var body = %Body
	#if direction:
		#body.scale.y = 1
		#body.rotation_degrees = 0
	#else:
		#body.scale.y = -1
		#body.rotation_degrees = 180


func _climb_R() -> bool:
	for i in %RightArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

func _climb_L() -> bool:
	for i in %LeftArea2D.get_overlapping_bodies():
		if i.is_in_group("Block"):
			return true
	return false

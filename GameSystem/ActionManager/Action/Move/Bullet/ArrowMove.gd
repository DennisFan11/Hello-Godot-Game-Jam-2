class_name ArrowMove
extends BulletMove

@export var default_degree: int = 45

var jump: bool = true
# 緩存重力值，避免每幀調用 get_gravity()
var cached_gravity: Vector2
# 緩存是否已經計算初始速度
var initial_velocity_calculated: bool = false


func _ready() -> void:
	# 預先緩存重力值
	cached_gravity = target.get_gravity() if target else Vector2(0, 980)

func _physics_process(delta: float) -> void:
	if not enable: return

	# 只在初始跳躍時進行複雜計算
	if jump and not initial_velocity_calculated:
		calculate_initial_velocity()
		initial_velocity_calculated = true
		jump = false

	# 簡化的移動計算
	if not jump:
		target.velocity += cached_gravity * delta

	# 調整角度 - 只在速度改變時計算
	var current_velocity = target.velocity
	if current_velocity.length_squared() > 0.01: # 使用 length_squared 避免 sqrt
		target.rotation = current_velocity.angle()

	# 碰撞檢測 - 移動後檢查
	if target.move_and_slide():
		handle_collision()

# 將複雜的初始速度計算分離到單獨函數
func calculate_initial_velocity():
	var pos = _get_player_distance()
	
	# 預計算角度值
	var angle_sign = -1 if pos.x > 0.0 else 1
	var rad = deg_to_rad(90 + default_degree * angle_sign)
	var cos_rad = cos(rad)
	var sin_rad = sin(rad)
	var tan_rad = tan(rad)
	
	# 計算初始速度
	var denominator = 2 * cos_rad * cos_rad * (pos.x * tan_rad + pos.y)
	if denominator <= 0:
		# 避免除零或負數開方
		target.velocity = Vector2.ZERO
		return
		
	var v0 = sqrt((cached_gravity.y * pos.x * pos.x) / denominator)
	
	# 設定速度
	target.velocity = Vector2(v0 * cos_rad, -v0 * sin_rad)
	
	# 限制最高速度
	target.velocity.x = clamp(target.velocity.x, -MAX_SPEED.x, MAX_SPEED.x)
	target.velocity.y = max(target.velocity.y, -MAX_SPEED.y)
	
	# 增加隨機
	target.velocity += get_variance_vec()

# 分離碰撞處理邏輯
func handle_collision():
	var collision = target.get_last_slide_collision()
	if collision:
		print(collision.get_collider().get_script().get_global_name())
	target.velocity = Vector2.ZERO
	enable = false

class_name BulletMove
extends Move

@export_group("variance")
## 啟用後增加投射物的分散度
@export var variance_enable:bool = true
## 分散度調整
## 數值越大越分散
## 當數值皆為0時預設為最大速度的10%
@export var variance_range:Vector2 = Vector2.ZERO

func get_variance_vec():
	if not variance_enable:
		return Vector2.ZERO

	if variance_range == Vector2.ZERO:
		variance_range = MAX_SPEED / 10

	return Vector2(
		randf_range(-variance_range.x, variance_range.x),
		randf_range(-variance_range.y, variance_range.y)
	)

class_name SummaryPanel
extends Control

signal finish()

func _ready() -> void:
	%SummaryButton.pressed.connect(_on_button_click)

func _open() -> void:
	visible = true
    # TODO 取得各項數值
	%SummaryContext.text = "擊殺敵人數: 0\n武器拼接數: 0\n獲得金幣數: 0"
	

func _on_button_click() -> void:
	# 關閉摘要面板
	visible = false
	# 發出 finish 信號
	finish.emit()

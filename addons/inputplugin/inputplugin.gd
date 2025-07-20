@tool
class_name InputPlugin
extends EditorPlugin

func _handles(object):
	# 只處理自定義類型或 Node2D 類型
	return object is Node2D

func _forward_canvas_draw_over_viewport(viewport):
	# 在編輯器畫出紅圈（例如滑鼠位置）
	viewport.draw_circle(viewport.get_local_mouse_position(), 8, Color.RED)

func _forward_canvas_gui_input(event):
	if not current_target:
		return false
	
	if event is InputEventMouseMotion:
		# 当光标被移动时，重绘视口。
		update_overlays()
		return true

	if event is InputEventMouseButton:
		input_event.emit(event)
		return true
	
	return false


signal input_event(event)



var current_target: Node = null

func _edit(node: Object) -> void:
	if node is TerrainEditor:
		current_target = node
		node._input_plugin = self
		print("Plugin 接管：", node.name)
	else:
		current_target = null

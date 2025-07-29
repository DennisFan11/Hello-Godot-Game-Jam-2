extends Node

## DI 動態反射依賴注入器





## 依賴表
var _dependence: Dictionary = { # property : Object
}

## 註冊依賴項目
func register(property: String, instance) -> void:
	_dependence[property] = instance

## 手動獲取依賴 (由 GameLoop Manager觸發 確保所有依賴項目以註冊)
func injection(target_node: Node, recursive: bool=false):
	#print("injection: ", target_node)
	
	## 遞歸注入
	if recursive:
		for child: Node in target_node.get_children():
			await injection(child, true)
	
	await _injection(target_node)


func _ready() -> void:
	get_tree().node_added.connect(_injection)
	_auto_reg()
	

## 自動獲取依賴
func _injection(target_node: Node):
	for property:String in _dependence.keys():
		if property in target_node:
			target_node.set(property, _dependence[property])
	if target_node.has_method("_on_injected"):
		target_node._on_injected()

"""
func _ready() -> void:
	DI.register("_tilemap_manager", self)
## 
func _on_injected(): 
	pass
"""



func _auto_reg():
	pass
	#register("_building_config", preload("uid://bgqyjpa0ubmsi"))
#

func get_dependence(key:String, value = null):
	return _dependence.get(key, value)

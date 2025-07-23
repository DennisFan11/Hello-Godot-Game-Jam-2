class_name ActionManager
extends Node

## 保存角色行動
## 方便切換時指定對應行動
@export var action_group:Array[Action]

## 切換角色行動的指標
## 使用switch_phase(index)切換
## 此參數的格式應為Array[Array[int(action_group的index)]], 但godot不支援多維陣列的類型設定
@export var phase:Array[Array]

@export var target: Node2D

func set_children_target(t:Node2D = target):
	for children in get_children():
		if children is Action:
			children.set_target(t)

func _ready() -> void:
	if not target:
		target = get_parent()
	set_children_target()



## 加入更換行動的方法
func enable_action(e:bool = true):
	printt(target, get_children())
	for children in get_children():
		if children is Action:
			printt(children, children.target, children.enable, e)
			children.enable = e

## 關閉所有子節點並開啟action_list的行動
func switch_action(action_list):
		enable_action(false)
		for action in action_list:
			action.enable = true

func switch_action_index(index):
	var switch_action_list:Array[Action] = []

	if index is int:
		index = [index]
	if index is Array:
		var action_group_len = len(action_group)
		if action_group_len == 0:
			printerr("{0}.{1} does not exist action_group".format([target.name, self.name]))
			return false

		for i in index:
			if not i is int:
				printerr("index must be an int or int array")
				return false

			if i >= 0 or i < action_group_len:
				switch_action_list.append(action_group[index])
			else:
				printerr(
					"{0}.{1} does not exist action_group[{2}]"
					.format([target.name, self.name, index])
				)
				return false
	else:
		printerr("index must be an int or int array")
		return false

	if switch_action_list:
		switch_action(switch_action_list)
		return true
	return false

func switch_phase(index:int):
	if index < 0 or index >= len(phase):
		return switch_action_index(phase[index])
	else:
		printerr(
			"{0}.{1} does not exist phase[{2}]"
			.format([target.name, self.name, index])
		)
		return false

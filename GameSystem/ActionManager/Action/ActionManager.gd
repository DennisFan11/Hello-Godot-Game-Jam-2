class_name ActionManager
extends Node

## 保存角色行動
## 方便切換時指定對應行動
@export var action_group:Array[Action]

## 切換角色行動的指標
## 使用switch_phase(index)切換
## 此參數的格式應為Array[Array[int(action_group的index)]], 但godot不支援多維陣列的類型設定
@export var phase:Array[ActionPhase]
@export var phase_loop:bool = false

@export var target: Node2D

var current_phase:int = -1



func _ready() -> void:
	if not target:
		target = get_parent()
	set_children_target()
	next_phase()

func set_children_target(t:Node2D = target):
	for children in get_children():
		if children is Action:
			children.set_target(t)



func get_enable_action():
	return get_children().filter(
		func(c): return c.enable
	)



## 加入更換行動的方法

## 
func enable_action(e:bool = true):
	for children in get_children():
		if children is Action:
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
				print(action_group[i])
				switch_action_list.append(action_group[i])
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
	if index >= 0 and index < len(phase):
		current_phase = index
		var phase_data = phase[index]
		if phase_data and phase_data.action_index:
			return switch_action_index(phase_data.action_index)
		else:
			return true
	else:
		printerr(
			"{0}.{1} does not exist phase[{2}]"
			.format([target.name, self.name, index])
		)
		return false

func next_phase():
	var index = -1
	if not len(phase):
		return false
	elif current_phase < 0:
		index = 0
	elif current_phase + 1 < len(phase):
		index = current_phase + 1
	elif phase_loop:
		index = 0
	else:
		return false
	return switch_phase(index)

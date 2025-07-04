extends Node

var _map_data: Dictionary = {}
const PATH = "user://save_game.dat"

# PUBLIC

## 可能返回 null
func get_key(key: String)-> Dictionary: 
	return _map_data[key]

func set_key(key: String, value:Dictionary)-> void:
	_map_data[key] = value


func save_file(path: String):
	_save_to_file(path)

func load_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	_load_from_file(path)
	return true



# PRIVATE

func _save_to_file( path: String )-> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(_map_data))
	file.close()


func _load_from_file( path: String )-> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	_map_data = JSON.to_native(JSON.parse_string(content))

extends Node


var _save_map: Dictionary[String, Object] = {}

func save_object(key: String, obj: Object):
	_save_map[key] = obj
	
func load_object(key: String)-> Object:
	return _save_map.get(key, null)

func clear()-> void:
	_save_map.clear()

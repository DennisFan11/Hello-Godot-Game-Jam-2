extends Node


var _save_map: Dictionary[String, Variant] = {}

func save_object(key: String, obj: Variant):
	_save_map[key] = obj
	
func load_object(key: String) -> Variant:
	return _save_map.get(key, null)

func clear() -> void:
	_save_map.clear()

class_name SaveResource
extends Resource



func _init(load_path:String = ""):
	if load_path.is_absolute_path():
		load_file(load_path)



func get_data():
	pass

func set_data(_data):
	pass



func save_file(path):
	var data = get_data()
	return ConfigRepo.save_resource(path, data)

func load_file(path):
	var data = ConfigRepo.load_resource(path)
	if data:
		set_data(data)
		return data
	return null

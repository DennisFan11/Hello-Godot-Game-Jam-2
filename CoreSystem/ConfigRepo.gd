extends Node
const PATH = "user://config.cfg"

const key = "596F55466F556E4454684550615373576F526421"

var repo:ConfigFile = null

func _ready() -> void:
	repo = ConfigFile.new()
	repo.load(PATH)
	
func save():
	return repo.save(PATH)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		await save()
		get_tree().quit() # default behavior
	if what == NOTIFICATION_APPLICATION_PAUSED:
		save()



func save_resource(path:String, data):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, key)
	if file:
		return file.store_var(data)
	return false

func load_resource(path:String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, key)
	if file:
		return file.get_var()
	return null

extends Node
const PATH = "user://config.cfg"


var repo:ConfigFile = null

func _ready() -> void:
	repo = ConfigFile.new()
	#Logger.printLog( "[CONFIG] load: ", repo.load(PATH) )
	
func save():
	return repo.save(PATH)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		await save()
		get_tree().quit() # default behavior
	if what == NOTIFICATION_APPLICATION_PAUSED:
		save()

extends Interactable

func interact() -> void:
	var meetings_count = InGameSaveSystem.load_object("meetings_count")
	if not meetings_count:
		meetings_count = 0
	InGameSaveSystem.save_object("meetings_count", meetings_count + 1)
	CoreManager.start_event("GodSceneManager")

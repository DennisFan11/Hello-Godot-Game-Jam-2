extends Interactable

var _has_activated: bool = false

func interact() -> void:
	if _has_activated:
		print("Already activated")
		return
	%RichTextLabel.text = "進入湖泊的通道消失了..."
	_has_activated = true
	var meetings_count = InGameSaveSystem.load_object("meetings_count")
	if not meetings_count:
		meetings_count = 0
	InGameSaveSystem.save_object("meetings_count", meetings_count + 1)
	CoreManager.start_event("GodSceneManager")

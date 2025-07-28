extends Node

const SECTION = "SoundManager"
func _ready() -> void:
	_load()

func _load():
	for i in _bus_map.keys():
		set_db(i, get_db(i))


enum BUS {MASTER, BGM, EFFECT}
var _bus_map = {
	BUS.MASTER: "Master",
	BUS.BGM: "Bgm",
	BUS.EFFECT: "Effect",
}

func get_db(bus: BUS):
	return ConfigRepo.repo.get_value(
		SECTION, _bus_map[bus], 1.0)

func set_db(bus: BUS, new: float):
	new = clampf(new, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(
			AudioServer.get_bus_index(_bus_map[bus]), new
		)
	ConfigRepo.repo.set_value(SECTION, _bus_map[bus], new)


var sound_list = {
	#"hurt": [preload("uid://bllmy0gmcpc2f"), 1.0],
	#"explo": [preload("uid://cit3h6tt0km8"), 1.0],
	#"shoot": [preload("uid://blf6wxb02piep"), 1.0],
	#"echo": [preload("uid://btct5onx5q7jk"), 1.0],
	#"coin":[preload("uid://bhxhprtjvo33w"), 1.0],
	#"mine":[preload("uid://biynwe3tookg0"), 0.2],
	#"type":[preload("uid://b2w1ht8wygs6g"), 1.0]
}
func play_sound(tag: String, position: Vector2):
	var sound := AudioStreamPlayer2D.new()
	sound.volume_linear = sound_list[tag][1]
	sound.stream = sound_list[tag][0]
	sound.position = position
	sound.bus = _bus_map[BUS.EFFECT]
	add_child(sound)
	sound.play()
	
	# 播放結束後自動移除
	sound.finished.connect(sound.queue_free)

func play_stream_sound(stream: AudioStream, position: Vector2, volume_linear: float):
	var sound := AudioStreamPlayer2D.new()
	sound.volume_linear = volume_linear
	sound.stream = stream
	sound.position = position
	sound.bus = _bus_map[BUS.EFFECT]
	add_child(sound)
	sound.play()
	
	# 播放結束後自動移除
	sound.finished.connect(sound.queue_free)

var bgm_list = {
	"title_music": preload("uid://b0ggxd0mr46i1"),
	"battle_music_1": preload("uid://dgufcxkt1jsdp")
} # by lolurio


const TIME = 5.0
var _player:AudioStreamPlayer = null

func play_bgm(bgm="test_menu")-> void:
	stop_bgm()
	_last_bgm_play = bgm
	_player = AudioStreamPlayer.new()
	_player.bus = "Bgm"
	_player.autoplay = true
	_player.stream = bgm_list[bgm]
	_player.volume_linear = 0.0
	_player.finished.connect(_player.play)
	var tween = get_tree().create_tween()
	tween.tween_property(_player, "volume_linear", 1.0, TIME)

	add_child(_player)

var stacked: bool = false
var _last_bgm_play:String = "game_normal"
func play_bgm_stack(bgm)-> void:
	if stacked:
		return
	stacked = true
	play_bgm(bgm)
	_player.finished.connect(func(): stacked=false)
	_player.finished.connect(play_bgm.bind("game_normal"))
	


func stop_bgm():
	if _player:
		var tween = get_tree().create_tween()
		tween.tween_property(_player, "volume_linear", 0.0, TIME)
		tween.tween_callback(_player.queue_free)

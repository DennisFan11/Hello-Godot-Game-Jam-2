class_name WaveManager
extends IGameSubManager

## PUBLIC ///////////////
@export var waveConfig:WaveConfig

## 忽視時間 直接生成下一波敵人
func force_next_wave()-> void:
	_next_wave()

func is_finish()-> bool:
	return waveConfig.WaveArray.is_empty()

func next_wave_left_time()-> float:
	return _next_wave_timer.get_left_time()




## PRIVATE ///////////////////

func _ready() -> void:
	DI.register("_wave_manager", self)
	waveConfig = waveConfig.duplicate(true)
	

var _is_started: bool = false
var _next_wave_timer := CooldownTimer.new()
var _enemy_manager: EnemyManager



func _game_start():
	_timer_init()
	_is_started = true
	



func _process(delta: float) -> void:
	if not _is_started:
		return 
	if is_finish():
		return 
	if not _next_wave_timer.is_ready():
		return 
	_next_wave()


func _timer_init()-> void:
	if not is_finish():
		_next_wave_timer.trigger(waveConfig.WaveArray[0].WaitTime)


## 生成一波敵人
func _next_wave():
	var wave: Wave = waveConfig.WaveArray.pop_front()
	if not wave:
		_next_wave_timer.trigger(0.1)
		return  
	
	if not is_finish():
		_next_wave_timer.trigger(waveConfig.WaveArray[0].WaitTime)
	
	for i: WaveEnemy in wave.Enemys:
		_enemy_manager.spawn_enemy(i)









#

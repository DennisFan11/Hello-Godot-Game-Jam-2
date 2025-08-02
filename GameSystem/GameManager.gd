class_name GameManager extends Node

## 前往下一關所需的擊殺數
@export var next_level_kill_count:int = 10

var kill_count:int = 0

func Save():
	await _recursive_call(self, "_save")
func Load():
	await _recursive_call(self, "_load")
func _game_start_recursive():
	await _recursive_call(self, "_game_start")

func _recursive_call(node: Node, method:String):
	if node.has_method(method):
		await node.call(method)
	for i:Node in node.get_children():
		await _recursive_call(i, method)



func _ready() -> void:
	print("GameManager 正在初始化...")
	
	# 註冊 GameManager 到 DI 系統
	DI.register("_game_manager", self)
	
	# 遞歸重新注入
	DI.injection(self, true)
	
	#SoundManager.play_bgm_stack("game_normal")
	await Load()
	await get_tree().process_frame
	await _game_start_recursive()
	
	%EnemyManager.enemy_died.connect(_on_enemy_died)
	#%PlayerManager.player_died.connect(func (c): finish(false))
	
	print("✓ GameManager 初始化完成")
	SoundManager.play_bgm("battle_music_1")

func _exit_tree() -> void:
	await Save()



func spawn_bullet(bullet:Bullet):
	%BulletManager.add_child(bullet)

func stop_game()-> void:
	set_process_mode(Node.PROCESS_MODE_DISABLED)
func continue_game()-> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

signal on_end(win:bool)
func finish(win:bool):
	on_end.emit(win)

## FIXME
func _on_enemy_died(enemy:Enemy):
	kill_count += 1
	print(kill_count, "/", next_level_kill_count, " ", enemy)
	#if kill_count >= next_level_kill_count:
		#finish(true)



func _on_boundary_body_entered(body: Node2D) -> void:
	if body is Character:
		body.dead()

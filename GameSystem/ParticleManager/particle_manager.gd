class_name ParticleManager
extends IGameSubManager

func _ready() -> void:
	DI.register("_particle_manager", self)

var _scene_map = {
	"Blood": preload("uid://mf63u76gof4f"),
	"BuildingDamage": preload("uid://bc8v8wtajfxju")
}


func create(type: String, global_pos: Vector2):
	var node: GPUParticles2D = \
		_scene_map[type].instantiate()
	node.global_position = global_pos
	node.emitting = true
	node.finished.connect(node.queue_free)
	add_child(node)

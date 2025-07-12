class_name GlobalGlueLayer
extends GlueLayer

func _ready() -> void:
	DI.register("_global_glue_layer", self)

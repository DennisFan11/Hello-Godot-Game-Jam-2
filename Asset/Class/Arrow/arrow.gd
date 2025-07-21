class_name Arrow
extends Line2D

var _vec: Vector2 = Vector2.ZERO
func set_vec(vec: Vector2)-> void:
	_vec = vec 

@export_multiline var text: String = "":
	set(new):
		text = new
		%RichTextLabel.text = text


func _process(delta: float) -> void:
	var fixed_vec = Vector2.from_angle(_vec.angle() - global_rotation) * _vec.length()
	points = [Vector2.ZERO, fixed_vec]
	
	%End.position = fixed_vec
	%End.rotation = fixed_vec.angle()
	
	%TextContainer.position = fixed_vec/2.0
	%TextContainer.rotation =  - global_rotation

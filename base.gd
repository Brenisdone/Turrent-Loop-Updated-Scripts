extends Sprite2D

@export var movement_speed := 0.01

var last_position: Vector2
var movement_offset := 0.0

func _ready() -> void:
	last_position = global_position

	# Important if multiple sprites use the same material
	material = material.duplicate()

func _process(_delta: float) -> void:
	var movement := global_position - last_position

	if movement.length() > 0.0:
		movement_offset += movement.length() * movement_speed
		material.set_shader_parameter("movement_offset", movement_offset)

	last_position = global_position

extends Area2D

@export var SPEED = 450
var is_power_shot:bool = false
var rotate = 0 #gets degrees

func _ready():
	$Sprite2D.play("default")

func _physics_process(delta):
	position += SPEED * Vector2(cos(rotate),sin(rotate)) * delta

func _on_vanish_timer_timeout():
	queue_free()

func _on_sprite_2d_animation_finished():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		$Sprite2D.play("on_hit")

func become_power_shot():
	is_power_shot = true
	$Sprite2D.scale = Vector2(1.0,1.0)
	$CollisionShape2D.shape.radius = 6

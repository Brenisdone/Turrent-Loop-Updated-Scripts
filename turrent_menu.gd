extends Node2D

var ghost_path: Node2D = null
var current_switch_area = null
@onready var current_path = $"../Paths/path"

var angle = 0
const ANGLE_MAP = {
	"switch_left": 180,
	"switch_right": 0,
	"switch_up": -90,
	"switch_down": 90
}

#turrent_vars
@export var rotation_speed := -1.5

var hold_time:float = 0.0
var triggered:bool = false

var turrent_paused:bool = true

func _ready():
	$Turrent_pivot/turrent.animation_finished.connect(_on_turrent_animation_finished)
	current_path.disable_all_switch_areas()
	current_path.turrent = self
	current_path.occupied = true


func _process(delta):
	
	if !turrent_paused:
		var rotating = get_global_mouse_position()
		if rotating.x > 320:
			$Turrent_pivot.rotation += rotation_speed * delta
		else:
			$Turrent_pivot.rotation -= rotation_speed * delta

	if Input.is_action_just_pressed('shoot'):
		shoot()
	if Input.is_action_pressed('shoot'):
		hold_time+=delta
		if Global.power_shot and hold_time >= 1.0:
			hold_time = 0.0
			triggered = true
			shoot()
	if Input.is_action_just_released("shoot"):
		hold_time = 0.0

	if current_switch_area:
		var path_node = current_switch_area.get_parent()
		path_node.disable_all_switch_areas()
		
		if !path_node.occupied:
			# Set turret pivot to this new path's position
			$Turrent_pivot.global_position = path_node.global_position
			$Turrent_pivot.global_rotation = deg_to_rad(angle) # or 180 depending on direction
			$Turrent_pivot.get_parent().rotation_speed *= -1
			current_path.enable_all_switch_areas()
			current_path.occupied = false;
			current_path = path_node
			current_path.occupied = true;
	follow_mouse()

func follow_mouse():
	$Turrent_pivot/turrent.look_at(get_global_mouse_position())

func shoot():
	$Turrent_pivot/turrent.play('shoot')
	$turrent_shooting.play()
	const bullet_scene = preload("res://scenes/bullet.tscn")
	var bullet_l = bullet_scene.instantiate()
	var bullet_r = bullet_scene.instantiate()
	if(triggered and Global.power_shot):
		bullet_l.become_power_shot()
		bullet_r.become_power_shot()
		triggered = false
	var angle = $Turrent_pivot/turrent.global_rotation
	bullet_l.rotate = angle
	bullet_r.rotate = angle
	bullet_l.global_position = $Turrent_pivot/turrent.global_position + Vector2.RIGHT.rotated(angle) * 30 + Vector2.UP.rotated(angle) * 6
	bullet_r.global_position = $Turrent_pivot/turrent.global_position + Vector2.RIGHT.rotated(angle) * 30 + Vector2.DOWN.rotated(angle) * 6
	get_parent().add_child(bullet_l)
	get_parent().add_child(bullet_r)
	bullet_l.name = 'Bullet'
	bullet_r.name = 'Bullet'

func _on_turrent_animation_finished():
	if $Turrent_pivot/turrent.animation == "shoot":
		$Turrent_pivot/turrent.play("idle")

func set_angle(area_str):
	angle = ANGLE_MAP.get(area_str,90)

func _on_turrent_damage_area_entered(area):
	if area.name.begins_with("switch_"):
		current_switch_area = area
		set_angle(current_switch_area.name)

func _on_turrent_damage_area_exited(area):
	if area == current_switch_area:
		current_switch_area = null

func pause_turrent():
	turrent_paused = true if !turrent_paused else false

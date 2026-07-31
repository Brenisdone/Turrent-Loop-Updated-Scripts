extends Node2D

const SPEED = 200
@export var health := 150
var turrent = null
var world = null
var move= true
var dead = false

var distracted:bool = false
var distraction_pos:Vector2

var aiming:bool = false
var can_shoot:bool = false
var shooting: bool = false
var shoot_cnt: int = 1

signal died(points)
signal damage(hitpoints)

@onready var enemy_sprite = $enemy_sprite
@onready var warning = $warning

func _ready():
	enemy_sprite.animation_finished.connect(_on_enemy_animation_finished)

#changes
#turrent.global_positon = turrent.target_location in process

func _process(delta):
	warning.rotation = -rotation
	if !distracted and !shooting and turrent!=null:
		var target_rotation = (turrent.target_location - global_position).angle()
		var range = abs(angle_difference(rotation,target_rotation))
		if aiming: check_aim(range)

		rotation = rotate_toward(rotation, target_rotation, 6.0*delta)
		
		if can_shoot and !shooting: start_shooting()

		if move:
			var direction = (turrent.target_location - global_position).normalized()
			position += direction * SPEED * delta
	elif distracted:
		rotation = (distraction_pos - global_position).angle()
		if move:
			var direction = (distraction_pos - global_position).normalized()
			position += direction * SPEED * delta

func _on_enemy_1_area_entered(area):
	if 'Bullet' in area.name:
		var power_shot:bool = area.is_in_group("player_bullet") and area.is_power_shot
		if(power_shot): health -= 200
		else: health-= 50
		$health_bar.value = health
		if health <= 0 and !dead:
			dead = true
			emit_signal('died',50)
			queue_free()

func _on_move_area_area_entered(area):
	if (area.name == 'turrent_damage' and !distracted):
		move = false
		aiming = true

func _on_distract_area_area_entered(area):
	if (area.name == 'ice_cream_area' and distracted):
		move = false

func _on_move_area_area_exited(area):
	if area.name == 'turrent_area' and !distracted:
		aiming = false
		can_shoot = false
		move = true

func _on_enemy_animation_finished():
	if $enemy_sprite.animation == 'shoot':
		$enemy_sprite.play("idle")

func shoot():
	if shoot_cnt <= 0:
		shooting = false
		$shoot_timer.stop()
		return
		
	const bullet_scene = preload("res://scenes/bullet_enemy.tscn")
	var spread_angles = [-10,-5,5,10]
	for spread in spread_angles:
		var bullet = bullet_scene.instantiate()
		var angle = global_rotation + deg_to_rad(spread)
		bullet.rotate = angle
		bullet.global_position = global_position + Vector2.RIGHT.rotated(angle) * 15
		get_parent().add_child(bullet)
		bullet.name = 'Bullet'
	$enemy_sprite.play("shoot")
	$enemy_shoot.play()
	shoot_cnt-=1

func _on_shoot_timer_timeout():
	if shooting and !distracted:
		shoot()

func get_distracted(pos:Vector2):
	distraction_pos = pos
	distracted = true
	if !move: move = true

func stop_distraction():
	distracted = false
	distraction_pos = Vector2.ZERO
	if !move: move = true

func start_shooting():
	move = false
	shooting = true
	shoot_cnt = 1
	$shoot_timer.wait_time = 0.1
	$enemy_anims.play("warning")

func check_aim(range: float):
	if range<0.05:
		can_shoot = true
	else:
		can_shoot = false

func _on_enemy_anims_animation_finished(anim_name):
	if anim_name == "warning":
		$shoot_timer.start()

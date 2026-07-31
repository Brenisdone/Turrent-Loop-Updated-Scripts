extends Node2D

const SPEED = 160
@export var health := 800
var turrent = null
var world = null

var dead:bool = false
var move= true
var is_attacking:bool = false

#signals
signal died(points)
signal damage(hitpoints)


@onready var hit_sfx = $hit_sfx
@onready var smash_sfx = $smash_sfx
@onready var enemy_sprite = $enemy_sprite
@onready var wheel_sprite = $wheel_sprite
@onready var health_bar = $health_bar

func _ready():
	health_bar.max_value = health
	health_bar.value = health
	enemy_sprite.animation_finished.connect(_on_enemy_animation_finished)

func _process(delta):
	if turrent!=null:
		rotation = (turrent.turrent_pos - global_position).angle()
		if move and !is_attacking:
			var direction = (turrent.turrent_pos - global_position).normalized()
			position += direction * SPEED * delta
		elif !move and !is_attacking:
				wheel_sprite.play("idle")
				enemy_sprite.play("smash")
				is_attacking = true

func _on_enemy_1_area_entered(area):
	if 'Bullet' in area.name:
		var power_shot:bool = area.is_in_group("player_bullet") and area.is_power_shot
		hit_sfx.play()
		if(power_shot): health -= 200
		else: health-= 50
		health_bar.value = health
		if health <= 0 and !dead:
			dead = true
			emit_signal('died',100)
			queue_free()

func _on_move_area_area_entered(area):
	if area.name == 'turrent_damage':
		move = false

func _on_move_area_area_exited(area):
	if area.name == 'turrent_damage':
		move = true

func _on_enemy_animation_finished():
	if enemy_sprite.animation == 'smash':
		is_attacking = false
		enemy_sprite.play("idle")
		smash_sfx.play()
		if !move:
			emit_signal('damage',30)
		wheel_sprite.play("moving")
		enemy_sprite.play("idle")

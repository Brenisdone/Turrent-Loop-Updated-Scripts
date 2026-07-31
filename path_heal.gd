extends Node2D

var turrent = null
var occupied = false

var cur_body = null
var can_heal:bool

@export var heal_points:int = 1

@onready var shock_wave = $shock_wave
@onready var shock = $shock
@onready var shock_round = $shock_round

@onready var heal_timer = $Heal_Timer
@onready var shock_sfx = $shock_sfx

signal damage(hitpoints)

func _ready():
	shock.play("default")
	shock_round.play("default")
	shock_wave.visible = false

func _process(delta):
	if can_heal and cur_body:
		shock_wave.rotation = get_angle_to(cur_body.turrent_pos)

func disable_all_switch_areas():
	for child in get_children():
		if child is Area2D and (child.name!='check' and child.name!='Heal_area'):
			child.monitoring = false
			child.monitorable=false
			
func enable_all_switch_areas():
	for child in get_children():
		if child is Area2D and (child.name!='check' and child.name!='Heal_area'):
			child.set_deferred("monitoring", true)
			child.set_deferred("monitorable", true)

#i am not even sure how the fuck this is even working
func _on_check_area_entered(area):
	occupied = true

func _on_check_area_exited(area):
	occupied = false

func _on_heal_area_body_entered(body):
	if body.name == "Turrent_body":
		shock_wave.visible = true
		shock_wave.play("default")
		shock_sfx.play()
		cur_body = body
		can_heal = true
		heal_timer.start()

func _on_heal_area_body_exited(body):
	if body.name == "Turrent_body":
		shock_wave.stop()
		shock_wave.visible = false
		shock_sfx.stop()
		cur_body = null
		can_heal = false

func _on_heal_timer_timeout():
	if can_heal and cur_body:
		cur_body.recieve_damage(-heal_points)
		heal_timer.start()

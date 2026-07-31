extends Node2D

var ghost_path: Node2D = null

var game_state = true #to check game over
var build = false      #to check build mode
var loop_cnt = 1

var current_switch_area = null
var current_path = null
var turrent_pos = 0
var angle = 0
const ANGLE_MAP = {
	"switch_left": 180,
	"switch_right": 0,
	"switch_up": -90,
	"switch_down": 90
}

var target_location:Vector2
var turrent_location:Vector2

#turrent and base refs
@onready var turrent = $Turrent_pivot/turrent
@onready var base = $Turrent_pivot/base

#health bar ref
@onready var health_bar = $Turrent_pivot/health_bar

@onready var camera = $"../Camera2D"

@onready var build_menu_anims = $build_menu_anims

@onready var boom = $boom
@onready var main = get_parent()

#turrent_vars
@export var rotation_speed := -2.2
@export var acceleration := 6.0
var cur_rot_speed := 0.0

#target_vars
var cur_target_lead := 0.0
var target_lead := 0.0
@export var target_lead_multiplier := 0.6
@export var target_lead_acceleration := 2.0

@export var total_health : int = 300
var health = total_health

#switch check : prevents turrent from switching continously
var can_switch = true
@onready var switch_timer = $"../Switch_Timer"

var loop_type = loop_types.NORMAL
enum loop_types{
	NORMAL,
	HEAL,
	DISTRACT
}
var loop_paths: Array = ["res://scenes/path.tscn","res://scenes/path_heal.tscn","res://scenes/path_distract.tscn"]
var loop_scores: Array = [200,1000,1500]
var loop_score = loop_scores[0]

#upgrade_vars
var hold_time:float = 0.0
var triggered:bool = false
@onready var upgrade_cooldown_timer = $"../Upgrade_Cooldown_Timer"

signal game_over
signal change_warning_text(text)
signal reset_multiplier

func _ready():
	$"..".end_game.connect(_on_game_over)
	$Turrent_pivot/turrent.animation_finished.connect(_on_turrent_animation_finished)
	boom.visible = false

	#setting up turrent
	base.texture = load(Global.cur_base_path) as Texture2D
	base.material = load(Global.cur_base_mat_path) as Material
	turrent.sprite_frames = load(Global.cur_turrent_spriteframes_path) as SpriteFrames
	
	#setup health bar
	health_bar.max_value = total_health
	health_bar.value = total_health
	
	#first path
	ghost_path = preload("res://scenes/path.tscn").instantiate()
	ghost_path.scale = Vector2(1.05,1.05)
	ghost_path.name = 'Path'
	ghost_path.disable_all_switch_areas()
	ghost_path.global_position = Vector2(0,0)
	ghost_path.turrent = self	
	get_tree().current_scene.add_child.call_deferred(ghost_path)
	current_path = ghost_path
	ghost_path = null

func _process(delta):
	if game_state:
		var rotating = Input.is_action_pressed('up') or Input.is_action_pressed('down')
		var target_speed := 0.0
		if rotating:
			if Input.is_action_pressed('up'):
				target_speed = -rotation_speed
			elif Input.is_action_pressed('down'):
				target_speed = rotation_speed
			
			#predictable aim
			target_lead = target_speed * target_lead_multiplier
			
			if not $turrent_screeching.playing:
				$turrent_screeching.play()
		else:
			target_lead = 0
			if $turrent_screeching.playing:
				$turrent_screeching.stop()

		if Input.is_action_just_pressed('shoot'):
			shoot()
		if Input.is_action_pressed('shoot'):
			hold_time+=delta
			if Global.power_shot and hold_time >= 1.0:
				hold_time = 0.0
				triggered = true
				shoot()
			elif Global.speed_boost and hold_time >= 1.0:
				hold_time = 0.0
				speed_boost()
		if Input.is_action_just_released("shoot"):
			hold_time = 0.0

		if Input.is_action_just_pressed("build"):
			build_mode()
		if Input.is_action_pressed("switch") and current_switch_area and can_switch:
			can_switch = false
			switch_timer.start()
			var path_node = current_switch_area.get_parent()
			path_node.disable_all_switch_areas()
			# Set turret pivot to this new path's position
			$Turrent_pivot.global_position = path_node.global_position
			$Turrent_pivot.global_rotation = deg_to_rad(angle) # or 180 depending on direction
			$Turrent_pivot.get_parent().rotation_speed *= -1
			#unsure about it at the moemnt
			cur_rot_speed = -cur_rot_speed
			current_path.enable_all_switch_areas()
			current_path = path_node
		if build:
			if Input.is_action_just_pressed('path_up'):
				update_ghost_position(0,-207)
			elif Input.is_action_just_pressed('path_down'):
				update_ghost_position(0,207)
			elif Input.is_action_just_pressed('path_left'):
				update_ghost_position(-207,0)
			elif Input.is_action_just_pressed('path_right'):
				update_ghost_position(207,0)
			elif Input.is_action_just_pressed('place'):
				place_path()
		
		var old_speed = cur_rot_speed
		
		cur_rot_speed = move_toward(
			cur_rot_speed,
			target_speed,
			acceleration*delta
		)
		
		cur_target_lead = move_toward(
			cur_target_lead,
			target_lead,
			target_lead_acceleration*delta
		)
		
		var is_decelerating  = abs(cur_rot_speed) < abs(old_speed)
		var is_moving = abs(cur_rot_speed) > 0.01
		
		$Turrent_pivot.rotation += cur_rot_speed * delta
		turrent_pos = $Turrent_pivot/turrent.global_position

		#predictable aim
		var radius = $Turrent_pivot/target.position.length()
		$Turrent_pivot/target.position = Vector2.RIGHT.rotated(cur_target_lead) * radius
		target_location = $Turrent_pivot/target.global_position

		if abs(cur_rot_speed) > 0.01:
			if not $turrent_screeching.playing:
				$turrent_screeching.play()
		else:
			if $turrent_screeching.playing:
				$turrent_screeching.stop()
				
		if is_decelerating and is_moving:
			if not $turrent_brakes.playing:
				$turrent_brakes.play()
		else:
			$turrent_brakes.stop()
		follow_mouse()
	else:
		if Input.is_action_pressed('place'):
			get_tree().reload_current_scene()

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
	#this angle is different from the above declared angle
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

func _on_turrent_damage_area_entered(area):
	if 'Bullet' in area.name and !area.is_in_group("player_bullet"):
		recieve_damage(10)
		if(Global.multiply_score): emit_signal("reset_multiplier")
		area.queue_free()
	elif area.name.begins_with("switch_"):
		current_switch_area = area
		set_angle(current_switch_area.name)

#rewriting this to act as change_health function
func recieve_damage(hitpoints):
	var net_health = health - hitpoints
	if(net_health >= total_health): return
	health -= hitpoints
	$Turrent_pivot/health_bar.value = health
	if health<=0:
		emit_signal('game_over')

func set_angle(area_str):
	angle = ANGLE_MAP.get(area_str,90)


func _on_turrent_damage_area_exited(area):
	if area == current_switch_area:
		current_switch_area = null

func _on_game_over():
	boom.global_position= $Turrent_pivot/turrent_area.global_position + Vector2(0,-40)
	boom.visible = true
	boom.play("boom")
	game_state = false

func build_mode():
	if ghost_path != null:
		build_menu_anims.play("build_menu_exit")
		ghost_path.queue_free()
		ghost_path = null
		build = false
	elif ghost_path == null:
		build_menu_anims.play("build_menu_entry")
		var ghost_path_scene_path = choose_loop_type(loop_type)
		var ghost_path_scene = load(ghost_path_scene_path) as PackedScene
		ghost_path = ghost_path_scene.instantiate()
		ghost_path.disable_all_switch_areas()
		ghost_path.modulate = Color(1, 1, 1, 0.3)
		ghost_path.scale = Vector2(1.05,1.05)
		get_tree().current_scene.add_child.call_deferred(ghost_path)
		update_ghost_position(207,0)
		build = true
	

func update_ghost_position(x,y):
	if ghost_path == null:
		return
	ghost_path.global_position = $Turrent_pivot.global_position + Vector2(x,y)

func place_path():
	if build:
		if ghost_path and !ghost_path.occupied and main.score>=loop_score:
			main.on_score_spent(loop_score)
			ghost_path.turrent = self
			ghost_path.modulate = Color(1,1,1,1)
			ghost_path.name = 'Path'
			ghost_path.enable_all_switch_areas()
			ghost_path = null
			loop_cnt+=1
			change_camera_zoom()
			build = false
			build_menu_anims.play("build_menu_exit")
		elif ghost_path and ghost_path.occupied:
			emit_signal("change_warning_text","You can't place that there mate!")
			$"../Warning_Timer".start()
		else:
			emit_signal("change_warning_text","Not enough score to spend!")
			$"../Warning_Timer".start()

func change_camera_zoom():
	if(camera.zoom.x>0.5 and loop_cnt%2==0):
		var tween = get_tree().create_tween()
		tween.tween_property(camera,"zoom",camera.zoom - Vector2(0.1,0.1), 0.3)

func choose_loop_type(loop_type):
	match loop_type:
		loop_types.NORMAL:
			loop_score = loop_scores[0]
			return loop_paths[0]
		loop_types.HEAL:
			loop_score = loop_scores[1]
			return loop_paths[1]
		loop_types.DISTRACT:
			loop_score = loop_scores[2]
			return loop_paths[2]

func _on_switch_timer_timeout():
	can_switch = true

#upgrade_related_funcs
func speed_boost():
	upgrade_cooldown_timer.start()
	rotation_speed = -3.0 if rotation_speed < 0 else 3.0
	acceleration = -8.0 if acceleration < 0 else 8.0

func _on_upgrade_cooldown_timer_timeout():
	rotation_speed = -2.2 if rotation_speed < 0 else 2.2
	acceleration = -6.0 if acceleration < 0 else 6.0

extends Node2D
var game_state = true

var score = 0
var multiplier:int = 1
var luck:int = 0
var level = 0
var time = 0 #overall_time
var spawn_time:float = 5.0 #inital timer value
var mode:String = "attack"

var enemies:Array = ["res://scenes/enemy_1.tscn","res://scenes/enemy_2.tscn","res://scenes/enemy_3.tscn"]
var musics:Array = ["res://sounds/attack_mode_music.ogg","res://sounds/build_mode_music.ogg"]
@onready var background_music = $background_music

# ChunkManager
var biome_noise = FastNoiseLite.new()
const CHUNK_SIZE = 16        # tiles per chunk
const LOAD_RADIUS = 3        # chunks around camera to keep loaded

var loaded_chunks = {}       # Dictionary: Vector2i → true
var world_seed = 42
@onready var tile_map = $TileMapLayer

#Timers
@onready var attack_build_timer = $Attack_Build_Timer
@onready var spawn_timer = $Spawn_Timer

var base_time:float = 0.5

#ui
@onready var game_over = $UI_Canvas/Game_Over
@onready var game_over_text = $UI_Canvas/Game_Over/Game_Over_Text

@onready var warning_text = $UI_Canvas/Player_Info/build_info_margin/build_info/warning
@onready var loop_btns = $UI_Canvas/Player_Info/build_info_margin/build_info/HBoxLoopsContainer

@onready var score_disp_text = $UI_Canvas/Player_Info/Margin_Container/VBoxContainer/score
@onready var level_disp_text = $UI_Canvas/Player_Info/Margin_Container/VBoxContainer/level

@onready var music_check = $UI_Canvas/Pause/MarginContainer/VBoxContainer/music/music_check
@onready var sfx_check = $UI_Canvas/Pause/MarginContainer/VBoxContainer/sfx/sfx_check

@onready var mode_text = $UI_Canvas/Player_Info/Margin_Container/VBoxContainer3/HBoxContainer/Mode
@onready var timer_text = $UI_Canvas/Player_Info/Margin_Container/VBoxContainer3/HBoxContainer/Timer

@onready var skip_btn = $UI_Canvas/Player_Info/Margin_Container/VBoxContainer3/skip_btn

@onready var pop_up_anims = $Pop_up_anims

var in_exit = false
var in_input_menu = false

#turrent_reference
@onready var turrent_body = $Turrent_body

#rng for spawning enemies
var rng = RandomNumberGenerator.new()

#signals
signal end_game

func _ready():
	rng.randomize()
	#assigned biome noise seed to rng to create new biome on each run
	biome_noise.seed = rng.seed
	biome_noise.frequency = 0.007
	
	#attak_build_timer is set to autostart
	spawn_timer.start()
	spawn_timer.wait_time = spawn_time
	
	music_check.button_pressed = Global.music
	sfx_check.button_pressed = Global.sfx
	
	$Turrent_body.game_over.connect(_on_game_over)
	$Turrent_body.change_warning_text.connect(change_warning_text)
	$Turrent_body.reset_multiplier.connect(reset_score_multiplier)
	game_over.visible = false
	warning_text.visible = false

	background_music.play()

func _process(delta):
	timer_text.text = str(snapped(attack_build_timer.time_left,0.1))

	var cam_chunk = get_camera_chunk()

	# Load nearby chunks
	for dx in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
		for dy in range(-LOAD_RADIUS, LOAD_RADIUS + 1):
			var c = cam_chunk + Vector2i(dx, dy)
			generate_chunk(c)

	# Unload distant chunks
	for chunk_pos in loaded_chunks.keys():
		if chunk_pos.distance_to(cam_chunk) > LOAD_RADIUS + 1:
			erase_chunk(chunk_pos)

func get_spawn_point():
	var offset_x = (-1 if rng.randi_range(0, 1) == 0 else 1)* (640 + rng.randi_range(0, 100))
	var offset_y = (-1 if rng.randi_range(0, 1) == 0 else 1) * (360 + rng.randi_range(0, 100))
	var spawn_point = $Camera2D.global_position + Vector2(offset_x, offset_y)
	return spawn_point

func choose_enemy():
	var index = rng.randi_range(0,enemies.size()-1)
	return enemies[index]

func _on_spawn_timer_timeout():
	time+=spawn_timer.wait_time
	
	var spawn_point = get_spawn_point()
	var enemy_scene_path = choose_enemy()
	var enemy_scene = load(enemy_scene_path) as PackedScene
	var enemy = enemy_scene.instantiate()
	
	enemy.position = spawn_point
	enemy.turrent = $Turrent_body
	enemy.died.connect(_on_enemy_died)
	enemy.damage.connect(on_recieved_damage)
	add_child(enemy)
	spawn_timer.start()

func _on_enemy_died(points):
	if(Global.luck_score): luck = randi_range(0,1000)
	score += (points * multiplier) + luck
	if(Global.multiply_score): multiplier+=1
	score_disp_text.text = str(score)

func reset_score_multiplier():
	multiplier = 1

func on_recieved_damage(hitpoints):
	turrent_body.recieve_damage(hitpoints)

func get_decrement() -> float:
	var t = spawn_timer.wait_time
	if t>1.0:
		return 1.0
	elif t>0.1:
		return 0.1
	elif t>0.01:
		return 0.01
	else:
		return 0.001

#fix this
func level_up():
	level += 1
	spawn_timer.wait_time *= 0.75
	level_disp_text.text = str(level)

func on_score_spent(cost_score):
	score-=cost_score
	score_disp_text.text = str(score)

func _on_game_over():
	if game_state:
		Global.total_score += score
		save_score(Global.total_score)
		game_state = false
		$Game_over_Timer.start()
		emit_signal('end_game')
		spawn_timer.paused = true
		attack_build_timer.paused = true
		var mins = time/60
		var secs = int(time)%60
		var text = "GAME OVER!\n\nYour total score: %d\nTime survived: %02d:%02d\nLoops: %d\n\npress ENTER to restart" %[score,mins,secs,$Turrent_body.loop_cnt]
		game_over_text.text = text

func _on_attack_build_timer_timeout():
	if(mode == "attack"):
		mode = "build"
		background_music.stream = load(musics[1])
		background_music.play()
		skip_btn.visible = true
		mode_text.text = "Build : "
		spawn_timer.stop()
	else:
		level_up()
		skip_btn.visible = false
		mode = "attack"
		background_music.stream = load(musics[0])
		background_music.play()
		mode_text.text = "Attack : "
		spawn_timer.start()

func change_warning_text(text):
	warning_text.text = text;
	warning_text.visible = true;

func _on_warning_timer_timeout():
	warning_text.visible = false

func _on_game_over_timer_timeout():
	loop_btns.visible = false
	score_disp_text.visible = false
	level_disp_text.visible = false
	mode_text.visible = false
	timer_text.visible = false
	game_over.visible = true

#Procedural Map Generation
#get tile on which camera is positioned
func get_camera_chunk() -> Vector2i:
	var cam_tile = tile_map.local_to_map(get_viewport().get_camera_2d().global_position)
	return world_to_chunk(cam_tile)

#Find chunk coordinates from tile
func world_to_chunk(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(tile_pos.x) / CHUNK_SIZE),
		floori(float(tile_pos.y) / CHUNK_SIZE)
		)

func get_biome(tile_x: int, tile_y: int) -> int:
	var v = biome_noise.get_noise_2d(tile_x,tile_y)
	if v< -0.2:
		return 1
	elif v<0.3:
		return 0
	else:
		return 2

#pick tile for biome
func get_random_tile(biome: int) -> Vector2i:
	if biome == 2:
		var roll = randf()
		if roll < 0.07:
			var rare = [Vector2i(4,0),Vector2i(6,0)]
			return rare[randi()%rare.size()]
		else:
			var common = [Vector2i(0,0),Vector2i(2,0)]
			return common[randi()%common.size()]
	var variants = {
		0: [Vector2i(0,0), Vector2i(2,0), Vector2i(4,0), Vector2i(6,0)],  # grass variants
		1: [Vector2i(0,0), Vector2i(2,0), Vector2i(4,0), Vector2i(6,0)],  # desert variants
	}
	var options = variants[biome]

	return options[randi() % options.size()]

#Create the chunk
func generate_chunk(chunk_pos: Vector2i):
	if loaded_chunks.has(chunk_pos):
		return

	seed(world_seed + chunk_pos.x * 1619 + chunk_pos.y * 31337)

	var origin = chunk_pos * CHUNK_SIZE

	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			var tile_pos = origin + Vector2i(x, y)
			var biome = get_biome(tile_pos.x, tile_pos.y)
			var tile = get_random_tile(biome)
			tile_map.set_cell(tile_pos, biome, tile)

	loaded_chunks[chunk_pos] = true

#Erase the chunk
func erase_chunk(chunk_pos: Vector2i):
	var origin = chunk_pos * CHUNK_SIZE
	for y in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			tile_map.erase_cell(origin + Vector2i(x, y))
	loaded_chunks.erase(chunk_pos)

func _on_music_check_toggled(toggled_on):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),!toggled_on)
	Global.music = !Global.music

func _on_sfx_check_toggled(toggled_on):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),!toggled_on)
	Global.sfx = !Global.sfx

func _on_loop_normal_pressed():
	turrent_body.loop_type = turrent_body.loop_types.NORMAL
	if turrent_body.ghost_path != null:
		turrent_body.ghost_path.queue_free()
		change_loop_type()

func _on_loop_heal_pressed():
	turrent_body.loop_type = turrent_body.loop_types.HEAL
	if turrent_body.ghost_path != null:
		turrent_body.ghost_path.queue_free()
		change_loop_type()

func _on_loop_distract_pressed():
	turrent_body.loop_type = turrent_body.loop_types.DISTRACT
	if turrent_body.ghost_path != null:
		turrent_body.ghost_path.queue_free()
		change_loop_type()

func change_loop_type():
	var ghost_path_scene_path = turrent_body.choose_loop_type(turrent_body.loop_type)
	var ghost_path_scene = load(ghost_path_scene_path) as PackedScene
	turrent_body.ghost_path = ghost_path_scene.instantiate()
	turrent_body.ghost_path.disable_all_switch_areas()
	turrent_body.ghost_path.modulate = Color(1, 1, 1, 0.3)
	turrent_body.ghost_path.scale = Vector2(1.05,1.05)
	turrent_body.get_tree().current_scene.add_child.call_deferred(turrent_body.ghost_path)
	turrent_body.update_ghost_position(207,0)
	
func _on_skip_btn_pressed():
	skip_btn.visible = false
	mode = "attack"
	mode_text.text = "Attack : "
	level_up()
	background_music.stream = load(musics[0])
	background_music.play()
	attack_build_timer.start()
	spawn_timer.start()

func save_score(new_score: int):
	var data = {}
	if FileAccess.file_exists(Global.SAVE_PATH):
		var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			data = json.data
	data["total_score"] = new_score
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

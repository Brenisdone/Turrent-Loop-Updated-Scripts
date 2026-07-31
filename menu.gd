extends Control

@onready var pop_up_anims = $Pop_up_anims

var turrent_paused:bool = false

var in_exit: bool = false
var in_mode_menu: bool = false
var in_settings: bool = false
var in_info_menu: bool = false
var in_input_menu: bool = false
var in_store:bool = false
var in_upgrades:bool = false

var mode = modes.Survival
enum modes{
	Survival,
	Endless,
	Multiplayer
}

@onready var modes_title = $Modes/MarginContainer/VBoxContainer/HBoxContainer/Mode_details_container/Title
@onready var modes_desc = $Modes/MarginContainer/VBoxContainer/HBoxContainer/Mode_details_container/Desc

@onready var info_img = $Info/MarginContainer/Text/Text_margin_container/Description/screenshot
@onready var info_title = $Info/MarginContainer/Text/Title
@onready var info_desc_text = $Info/MarginContainer/Text/Text_margin_container/Description/Desc/Desc_text

@onready var input_settings_ref = $InputSettings
@onready var store_ref = $Store
@onready var upgrades = $Upgrades


#turrent_refs
@onready var base = $Turrent_loop/Turrent_menu/Turrent_pivot/base
@onready var turrent = $Turrent_loop/Turrent_menu/Turrent_pivot/turrent
var slides: Array[Dictionary] =[
	{
		"title":"DESCRIPTION",
		"desc":"""Weclome to Turrent Loop!
Shoot enemies and Build paths 
to Survive each Level
Difficulty increases with Each Level""",
	},
	{
		"title":"ATTACK MODE",
		"desc":"""The first min is the attack mode.
Two types of enemies can spawn
Shooters: low health,fast,light damage
Tank: high health,slow,heavy damage""",
	},
	{
		"title":"BUILD MODE",
		"desc":"""The second min is the build mode.
Two special loops can be placed.
Heal: Heals the turrent every sec
Distract: Distracts shooters nearby""",
	},
]

var slide_imgs: Array[String] = ["res://sprites/info_imgs/description.png","res://sprites/info_imgs/attack_mode.png","res://sprites/info_imgs/build_mode.png"]

var cur_slide = 0
var max_slide = slides.size() 


func _ready():
	input_settings_ref.close_requested.connect(_close_input_pressed)
	store_ref.store_close_requested.connect(_store_close_pressed)
	upgrades.upgrades_close_requested.connect(_upgrades_close_presssed)
	
	load_score()
	pop_up_anims.play("Title_enter")
	
	base.texture = load(Global.cur_base_path) as Texture2D
	base.material = load(Global.cur_base_mat_path) as Material
	turrent.sprite_frames = load(Global.cur_turrent_spriteframes_path) as SpriteFrames

func _input(event):
	if pop_up_anims.is_playing():  # ← block all input during transitions
		return
	if event.is_action_pressed("escape"):
		if !in_mode_menu and !in_settings and !in_info_menu and !in_input_menu and !in_store and !in_upgrades:
			if !in_exit:
				pop_up_anims.play("Exit_enter")
			else:
				pop_up_anims.play("Exit_exit")
			in_exit = !in_exit
		elif !in_settings and !in_info_menu and !in_input_menu and !in_store and !in_upgrades:
			pop_up_anims.play_backwards("Modes_enter")
			await pop_up_anims.animation_finished
			pop_up_anims.play("Title_enter")
			await pop_up_anims.animation_finished
			in_mode_menu = false
		elif !in_settings and !in_input_menu and !in_store and !in_upgrades:
			pop_up_anims.play_backwards("Info_enter")
			await pop_up_anims.animation_finished
			pop_up_anims.play("Title_enter")
			await pop_up_anims.animation_finished
			in_info_menu = false
		elif !in_settings and !in_input_menu and !in_store and !in_info_menu:
			pop_up_anims.play_backwards("upgrades")
			await pop_up_anims.animation_finished
			pop_up_anims.play("Title_enter")
			await pop_up_anims.animation_finished
			in_upgrades = false
		elif in_input_menu:
			_close_input_pressed()
		elif in_store:
			store_ref._on_exit_btn_pressed()
		else:
			pop_up_anims.play("Settings_exit")
			await pop_up_anims.animation_finished
			in_settings = false

func _on_start_game_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Title_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Modes_enter")
	await pop_up_anims.animation_finished
	in_mode_menu = true

func _on_quit_game_pressed():
	if pop_up_anims.is_playing(): return
	in_exit = true  # ← keep state in sync
	pop_up_anims.play("Exit_enter")

func _on_yes_pressed():
	get_tree().quit(0)

func _on_no_pressed():
	if pop_up_anims.is_playing(): return
	in_exit = false  # ← keep state in sync
	pop_up_anims.play("Exit_exit")

func _on_settings_pressed():
	if pop_up_anims.is_playing(): return
	in_settings = true
	pop_up_anims.play("Settings_enter")

func _on_close_settings_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Settings_exit")
	await pop_up_anims.animation_finished
	in_settings = false

func _on_modes_exit_btn_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Modes_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Title_enter")
	await pop_up_anims.animation_finished
	in_mode_menu = false

func _on_info_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Title_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Info_enter")
	await pop_up_anims.animation_finished
	in_info_menu = true

func _on_info_exit_btn_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Info_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Title_enter")
	await pop_up_anims.animation_finished
	in_info_menu = false

func _on_upgrades_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Title_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("upgrades")
	await pop_up_anims.animation_finished
	in_upgrades = true

func _upgrades_close_presssed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("upgrades")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Title_enter")
	await pop_up_anims.animation_finished
	in_upgrades = false
	
#Settings checks
func _on_music_check_toggled(toggled_on):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),!toggled_on)
	Global.music = !Global.music

func _on_sfx_check_toggled(toggled_on):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"),!toggled_on)
	Global.sfx = !Global.sfx

#Modes confirm button
func _on_confirm_btn_pressed():
	if (mode == modes.Survival):
		SceneTransition.change_scene("res://scenes/world.tscn")

#Modes buttons
func _on_survival_btn_pressed():
	mode = modes.Survival
	modes_title.text = "SURVIVAL MODE"
	modes_desc.text = """•Classic mode
•Levels rise with kills
•Progress is not saved
•Goal is survive as long as you can
"""

func _on_endless_btn_pressed():
	mode = modes.Endless
	modes_title.text = "ENDLESS MODE"
	modes_desc.text = """•Respawn after death
•Loops are saved
•Goal is explore as long as you want
(COMING SOON)
"""

func _on_multiplayer_btn_pressed():
	mode = modes.Multiplayer
	modes_title.text = "MULTIPLAYER MODE"
	modes_desc.text = """•4 players
•Other players are treated as enemies
•Goal is capture as many loops as possible
(COMING SOON)   
"""

func _on_left_arrow_pressed():
	if cur_slide == 0: return
	else:
		cur_slide-=1
		info_img.texture = load(slide_imgs[cur_slide]) as Texture2D
		info_title.text = slides[cur_slide]["title"]
		info_desc_text.text = slides[cur_slide]["desc"]

func _on_right_arrow_pressed():
	if cur_slide == max_slide-1: return
	else:
		cur_slide+=1
		info_img.texture = load(slide_imgs[cur_slide]) as Texture2D
		info_title.text = slides[cur_slide]["title"]
		info_desc_text.text = slides[cur_slide]["desc"]

func _on_key_rebind_btn_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Settings_exit")
	await pop_up_anims.animation_finished
	pop_up_anims.play("input_entry")
	await pop_up_anims.animation_finished
	in_input_menu = true

func _close_input_pressed():
	pop_up_anims.play_backwards("input_entry")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Settings_enter")
	await pop_up_anims.animation_finished
	in_input_menu = false

func _on_store_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Title_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Store_enter")
	await pop_up_anims.animation_finished
	in_store = true

func _store_close_pressed():
	base.texture = load(Global.cur_base_path) as Texture2D
	base.material = load(Global.cur_base_mat_path) as Material
	turrent.sprite_frames = load(Global.cur_turrent_spriteframes_path) as SpriteFrames
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("Store_enter")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Title_enter")
	await pop_up_anims.animation_finished
	in_store = false

func load_score():
	if !FileAccess.file_exists(Global.SAVE_PATH):
		return

	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
	var json = JSON.new()

	if json.parse(file.get_as_text()) == OK:
		Global.total_score = json.data.get("total_score", 0)

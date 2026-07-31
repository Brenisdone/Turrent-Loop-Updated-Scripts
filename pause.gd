extends Control

@onready var pop_up_anims = $"../../Pop_up_anims"
@onready var input_settings_ref = $"../InputSettings"

var in_pause_menu: bool = false
var in_input_menu: bool = false
var in_exit_menu: bool = false
var pressed_exit_to_menu: bool = false

func _ready():
	input_settings_ref.close_requested.connect(_close_input_pressed)

func _input(event):
	if not event.is_action_pressed("escape") or pop_up_anims.is_playing(): return
	if not in_pause_menu and not in_input_menu:
		_on_pause_btn_pressed()
	elif in_exit_menu:
		_on_no_pressed()
	elif in_input_menu:
		_close_input_pressed()
	else:
		_on_close_settings_pressed()

func _on_pause_btn_pressed():
	get_tree().paused = true
	pop_up_anims.play("Settings_enter")
	await pop_up_anims.animation_finished
	in_pause_menu = true

func _on_close_settings_pressed():
	pop_up_anims.play("Settings_exit")
	await pop_up_anims.animation_finished
	get_tree().paused = false
	in_pause_menu = false

func _on_key_rebind_btn_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Settings_exit")
	await pop_up_anims.animation_finished
	pop_up_anims.play("input_entry")
	await pop_up_anims.animation_finished
	in_input_menu = true

func _close_input_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play_backwards("input_entry")
	await pop_up_anims.animation_finished
	pop_up_anims.play("Settings_enter")
	await pop_up_anims.animation_finished
	in_input_menu = false

func _on_exit_btn_pressed():
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Exit_enter")
	await pop_up_anims.animation_finished
	in_exit_menu = true

func _on_exit_btn_2_pressed():
	pressed_exit_to_menu = true
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Exit_enter")
	await pop_up_anims.animation_finished
	in_exit_menu = true
	
func _on_yes_pressed():
	if pressed_exit_to_menu:
		get_tree().paused = false
		SceneTransition.change_scene("res://scenes/menu.tscn")
	else:
		get_tree().quit(0)

func _on_no_pressed():
	pressed_exit_to_menu = false
	if pop_up_anims.is_playing(): return
	pop_up_anims.play("Exit_exit")
	await pop_up_anims.animation_finished
	in_exit_menu = false

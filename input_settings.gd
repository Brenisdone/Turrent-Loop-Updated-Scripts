extends Control

@onready var input_button_scene = preload("res://scenes/input_button.tscn")
@onready var action_list = $Panel/MarginContainer/VBoxContainer/ScrollContainer/ActionList

const INPUT_SETTINGS_PATH := "user://input_settings.cfg"

var is_remapping: bool = false
var action_to_remap = null
var remapping_btn = null

var input_actions: Dictionary = {
	"up": "move anti-clockwise",
	"down": "move clockwise",
	"shoot": "fire",
	"switch": "switch path",
	"path_up": "move path above",
	"path_down": "move path below",
	"path_left": "move path left",
	"path_right": "move path right",
	"place": "place path",
	"build": "switch modes",
}

signal close_requested

func _ready():
	InputMap.load_from_project_settings()
	_load_input_settings()
	_create_action_list()


func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()

	for action in input_actions:
		var button = input_button_scene.instantiate()
		var labelAction = button.find_child("LabelAction")
		var labelInput = button.find_child("LabelInput")

		labelAction.text = input_actions[action]

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			labelInput.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			labelInput.text = ""

		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))


func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_btn = button
		button.find_child("LabelInput").text = "Press key to bind..."


func _input(event):
	if is_remapping:
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			_create_action_list()
			is_remapping = false
			action_to_remap = null
			remapping_btn = null
			accept_event()
			return

		if event is InputEventKey and event.pressed:
			_remap_action(event)
			accept_event()
			return

		if event is InputEventMouseButton and event.pressed:
			_remap_action(event)
			accept_event()
			return


func _remap_action(event: InputEvent):
	InputMap.action_erase_events(action_to_remap)
	InputMap.action_add_event(action_to_remap, event)

	_update_action_list(remapping_btn, event)
	_save_input_settings()

	is_remapping = false
	action_to_remap = null
	remapping_btn = null


func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _save_input_settings():
	var config := ConfigFile.new()

	for action in input_actions:
		var events := InputMap.action_get_events(action)

		if events.size() > 0:
			config.set_value("input", action, events[0])

	config.save(INPUT_SETTINGS_PATH)


func _load_input_settings():
	var config := ConfigFile.new()
	var err := config.load(INPUT_SETTINGS_PATH)

	if err != OK:
		return

	for action in input_actions:
		if config.has_section_key("input", action):
			var event = config.get_value("input", action)

			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)


func _on_reset_button_pressed():
	InputMap.load_from_project_settings()
	_save_input_settings()
	_create_action_list()


func _on_exit_btn_pressed():
	close_requested.emit()

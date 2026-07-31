extends Control

@onready var score_label = $Panel/VBoxContainer/Top/HBoxContainer/Score
@onready var bottom_desc_text = $Panel/VBoxContainer/Bottom_desc_margins/VBoxContainer/Bottom_desc_text

var turrent_btns = {
	"power_shot": {
		"enabled": false,
		"bought": false,
		"score": 2500
	},
	"speed_boost": {
		"enabled": false,
		"bought": false,
		"score": 5000
	},
	"score_multiplier": {
		"enabled": false,
		"bought": false,
		"score": 7500
	},
	"luck_score": {
		"enabled": false,
		"bought": false,
		"score": 10000
	}
}

#turrent upgrade references
@onready var power_shot_buy_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Turrent_upgrades_grp/Power_shot_btn/Power_shot_buy_btn
@onready var power_shot_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Turrent_upgrades_grp/Power_shot_btn
@onready var speed_boost_buy_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Turrent_upgrades_grp/Speed_boost_btn/Speed_boost_buy_btn
@onready var speed_boost_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Turrent_upgrades_grp/Speed_boost_btn

#score upgraade references
@onready var score_multiplier_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Score_upgrades_grp/Score_multiplier_btn
@onready var score_multiplier_buy_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Score_upgrades_grp/Score_multiplier_btn/Score_multiplier_buy_btn
@onready var score_luck_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Score_upgrades_grp/Score_luck_btn
@onready var score_luck_buy_btn = $Panel/VBoxContainer/Upgrades_hbox_container/Score_upgrades_grp/Score_luck_btn/Score_luck_buy_btn

signal upgrades_close_requested

#initalily all buttons are disabled and buy button is visible
#the ready function iterates through enabled and bought states for each upgrade
func _ready():
	load_game()
	for key in turrent_btns:
		check_bought(key)
		check_enabled(key)
	update_score(0)

#buying buttons
func _on_power_shot_buy_btn_pressed():
	var id = turrent_btns["power_shot"]
	if(Global.total_score>=id["score"]):
		update_score(id["score"])
		id["bought"] = true
		check_bought("power_shot")

func _on_speed_boost_buy_btn_pressed():
	var id = turrent_btns["speed_boost"]
	if(Global.total_score>=id["score"]):
		update_score(id["score"])
		id["bought"] = true
		check_bought("speed_boost")

func _on_score_multiplier_buy_btn_pressed():
	var id = turrent_btns["score_multiplier"]
	if(Global.total_score>=id["score"]):
		update_score(id["score"])
		id["bought"] = true
		check_bought("score_multiplier")

func _on_score_luck_buy_btn_pressed():
	var id = turrent_btns["luck_score"]
	if(Global.total_score>=id["score"]):
		update_score(id["score"])
		id["bought"] = true
		check_bought("luck_score")

##toggling buttons
func _on_power_shot_btn_toggled(toggled_on):
	turrent_btns["power_shot"]["enabled"] = toggled_on
	Global.power_shot = toggled_on
	#print("toggle_on state: ",toggled_on)

func _on_speed_boost_btn_toggled(toggled_on):
	turrent_btns["speed_boost"]["enabled"] = toggled_on
	Global.speed_boost = toggled_on
	#print("toggle_on state: ",toggled_on)

func _on_score_multiplier_btn_toggled(toggled_on):
	turrent_btns["score_multiplier"]["enabled"] = toggled_on
	Global.multiply_score = toggled_on

func _on_score_luck_btn_toggled(toggled_on):
	turrent_btns["luck_score"]["enabled"] = toggled_on
	Global.luck_score = toggled_on


func update_score(score:int):
	Global.total_score -= score
	score_label.text = "Score:"+str(Global.total_score)

func check_bought(key:String):
	if(turrent_btns[key]["bought"]):
		if(key == "power_shot"):
			power_shot_buy_btn.visible = false
			power_shot_btn.disabled = false
			power_shot_btn.self_modulate = Color(1,1,1,1)
		if(key == "speed_boost"):
			speed_boost_buy_btn.visible = false
			speed_boost_btn.disabled = false
			speed_boost_btn.self_modulate = Color(1,1,1,1)
		if(key == "score_multiplier"):
			score_multiplier_buy_btn.visible = false
			score_multiplier_btn.disabled = false
			score_multiplier_btn.self_modulate = Color(1,1,1,1)
		if(key == "luck_score"):
			score_luck_buy_btn.visible = false
			score_luck_btn.disabled = false
			score_luck_btn.self_modulate = Color(1,1,1,1)

func check_enabled(key:String):
	if(turrent_btns[key]["enabled"]):
		if(key == "power_shot"):
			Global.power_shot = true
			power_shot_btn.set_pressed_no_signal(turrent_btns["power_shot"]["enabled"])
		if(key == "speed_boost"):
			Global.speed_boost = true
			speed_boost_btn.set_pressed_no_signal(turrent_btns["speed_boost"]["enabled"])
		if(key == "score_multiplier"):
			Global.multiply_score = true
			score_multiplier_btn.set_pressed_no_signal(turrent_btns["score_multiplier"]["enabled"])
		if(key == "luck_score"):
			Global.luck_score = true
			score_luck_btn.set_pressed_no_signal(turrent_btns["luck_score"]["enabled"])

func _on_exit_pressed():
	save_game()
	upgrades_close_requested.emit()

func save_game():
	var data = {}

	if FileAccess.file_exists(Global.SAVE_PATH):
		var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
		var json = JSON.new()

		if json.parse(file.get_as_text()) == OK:
			data = json.data

	data["total_score"] = Global.total_score
	data["turrent_btns"] = turrent_btns

	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_game():
	if !FileAccess.file_exists(Global.SAVE_PATH):
		return

	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.READ)
	var json = JSON.new()

	if json.parse(file.get_as_text()) == OK:
		var data = json.data

		Global.total_score = data.get("total_score", 0)

		if data.has("turrent_btns"):
			turrent_btns = data["turrent_btns"]

#update description of upgrades
func _on_power_shot_btn_mouse_entered():
	bottom_desc_text.text = """Hold shoot for 1 secs for bigger shots"""

func _on_power_shot_buy_btn_mouse_entered():
	bottom_desc_text.text = """Hold shoot for 1 secs for bigger shots"""

func _on_speed_boost_btn_mouse_entered():
	bottom_desc_text.text = """Hold shoot for 1 secs for 5 secs boost"""

func _on_speed_boost_buy_btn_mouse_entered():
	bottom_desc_text.text = """Hold shoot for 1 secs for 5 secs boost"""

func _on_score_multiplier_buy_btn_mouse_entered():
	bottom_desc_text.text = """Score earned from enemies is multiplied until you're hit by a bullet."""

func _on_score_multiplier_btn_mouse_entered():
	bottom_desc_text.text = """Score earned from enemies is multiplied until you're hit by a bullet."""

func _on_score_luck_buy_btn_mouse_entered():
	bottom_desc_text.text = """Gain bonus score from 0 to 500 for each kill"""

func _on_score_luck_btn_mouse_entered():
	bottom_desc_text.text = """Gain bonus score from 0 to 500 for each kill"""

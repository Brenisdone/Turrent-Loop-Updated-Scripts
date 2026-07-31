extends Control

#turrent and base name
@onready var turrent_name = $Panel/MarginContainer/VBoxContainer/HBoxContainer_turrent/Turrent_name
@onready var base_name = $Panel/MarginContainer/VBoxContainer/HBoxContainer_base/Base_name

var turrents:Array = [
	"res://sprites/turrent/TURRENT_1_STORE.png",
	"res://sprites/turrent/TURRENT_2_STORE.png",
	"res://sprites/turrent/TURRENT_3_STORE.png"
]

var turrent_spriteframes:Array = [
	"res://sprites/turrent_spriteframes/turrent_1_spriteframes.tres",
	"res://sprites/turrent_spriteframes/turrent_2_spriteframes.tres",
	"res://sprites/turrent_spriteframes/turrent_3_spriteframes.tres"
]

var turrent_names:Array = ["Default","Cheese","Ice"]

var bases:Array = [
	"res://sprites/base/BASE_1.png",
	"res://sprites/base/BASE_2.png",
	"res://sprites/base/BASE_3.png"
]

var base_mats:Array = [
	"res://shaders/base_mats/base_1_mat.tres",
	"res://shaders/base_mats/base_2_mat.tres",
	"res://shaders/base_mats/base_3_mat.tres"
]

var base_names:Array = ["Default","Cheese","Ice"]

@onready var control = $Panel/MarginContainer/VBoxContainer/Control

#base_text_rect_refs
@onready var base_prev = $Panel/MarginContainer/VBoxContainer/Control/Base_prev
@onready var base_cur = $Panel/MarginContainer/VBoxContainer/Control/Base
@onready var base_next = $Panel/MarginContainer/VBoxContainer/Control/Base_next

#base_text_rect_positions
var base_prev_pst:Vector2 = Vector2(0,0)
var base_cur_pst:Vector2 = Vector2(115,0)
var base_next_pst:Vector2 = Vector2(230,0)

var cur_base_idx := 0

#turrent_text_rect_refs
@onready var turrent_prev = $Panel/MarginContainer/VBoxContainer/Control/Turrent_prev
@onready var turrent_cur = $Panel/MarginContainer/VBoxContainer/Control/Turrent_cur
@onready var turrent_next = $Panel/MarginContainer/VBoxContainer/Control/Turrent_next

#base_text_rect_positions
var turrent_prev_pst:Vector2 = Vector2(0,0)
var turrent_cur_pst:Vector2 = Vector2(115,0)
var turrent_next_pst:Vector2 = Vector2(230,0)

var cur_turrent_idx := 0

signal store_close_requested

func _ready():
	load_data()
	
	#initalize bases
	cur_base_idx = Global.cur_base_idx
	var prev_idx = wrap_idx(cur_base_idx - 1)
	var next_idx = wrap_idx(cur_base_idx + 1)
	
	base_name.text = base_names[cur_base_idx]
	
	base_prev.texture = load(bases[prev_idx]) as Texture2D
	base_cur.texture = load(bases[cur_base_idx]) as Texture2D
	base_next.texture = load(bases[next_idx]) as Texture2D
	
	base_prev.material = load(base_mats[prev_idx]) as Material
	base_cur.material = load(base_mats[cur_base_idx]) as Material
	base_next.material = load(base_mats[next_idx]) as Material
	#new addtion below
	#refresh_base_texts()
	
	#initalize turrents
	cur_turrent_idx = Global.cur_turrent_idx
	prev_idx = wrap_idx(cur_turrent_idx - 1)
	next_idx = wrap_idx(cur_turrent_idx + 1)
	
	turrent_name.text = turrent_names[cur_turrent_idx]
	
	turrent_prev.texture = load(turrents[prev_idx]) as Texture2D
	turrent_cur.texture = load(turrents[cur_turrent_idx]) as Texture2D
	turrent_next.texture = load(turrents[next_idx]) as Texture2D

func _on_exit_btn_pressed():
	Global.cur_base_path = bases[cur_base_idx]
	Global.cur_base_idx = cur_base_idx
	Global.cur_base_mat_path = base_mats[cur_base_idx]
	
	Global.cur_turrent_path = turrents[cur_turrent_idx]
	Global.cur_turrent_idx = cur_turrent_idx
	Global.cur_turrent_spriteframes_path = turrent_spriteframes[cur_turrent_idx]
	
	save_data()
	store_close_requested.emit()

#select base and turrent arrow buttons handles here
#turrent arrow funcs
func _on_left_arrow_turrent_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(turrent_cur, "position", turrent_prev_pst,0.25)
	tween.tween_property(turrent_next, "position", turrent_cur_pst, 0.25)
	
	await tween.finished
	
	cur_turrent_idx = wrap_idx(cur_turrent_idx + 1)
	refresh_turrent_texts()

func _on_right_arrow_turrent_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(turrent_cur, "position", turrent_next_pst,0.25)
	tween.tween_property(turrent_prev, "position", turrent_cur_pst, 0.25)
	
	await tween.finished
	
	cur_turrent_idx = wrap_idx(cur_turrent_idx - 1)
	refresh_turrent_texts()

#base arrow funcs
func _on_left_arrow_base_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(base_cur, "position", base_prev_pst,0.25)
	tween.tween_property(base_next, "position", base_cur_pst, 0.25)
	
	await tween.finished
	
	cur_base_idx = wrap_idx(cur_base_idx + 1)
	#base_name.text = base_names[cur_base_idx]
	refresh_base_texts()
 
func _on_right_arrow_base_pressed():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(base_cur, "position", base_next_pst,0.25)
	tween.tween_property(base_prev, "position", base_cur_pst, 0.25)
	
	await tween.finished
	
	cur_base_idx = wrap_idx(cur_base_idx - 1)
	#base_name.text = base_names[cur_base_idx]
	refresh_base_texts()

func wrap_idx(i:int)->int:
	return (i + bases.size()) % bases.size()

func refresh_base_texts():
	#new addition from below
	var prev_idx = wrap_idx(cur_base_idx - 1)
	var next_idx = wrap_idx(cur_base_idx + 1)
	
	base_name.text = base_names[cur_base_idx]
	
	base_prev.texture = load(bases[prev_idx]) as Texture2D
	base_cur.texture = load(bases[cur_base_idx]) as Texture2D
	base_next.texture = load(bases[next_idx]) as Texture2D
	
	base_prev.material = load(base_mats[prev_idx]) as Material
	base_cur.material = load(base_mats[cur_base_idx]) as Material
	base_next.material = load(base_mats[next_idx]) as Material
	
	base_prev.position = base_prev_pst
	base_cur.position = base_cur_pst
	base_next.position = base_next_pst
	
	Global.cur_base_idx = cur_base_idx
	Global.cur_base_path = bases[cur_base_idx]
	Global.cur_base_mat_path = base_mats[cur_base_idx]

func refresh_turrent_texts():
	var prev_idx = wrap_idx(cur_turrent_idx - 1)
	var next_idx = wrap_idx(cur_turrent_idx + 1)
	
	turrent_name.text = turrent_names[cur_turrent_idx]
	
	turrent_prev.texture = load(turrents[prev_idx]) as Texture2D
	turrent_cur.texture = load(turrents[cur_turrent_idx]) as Texture2D
	turrent_next.texture = load(turrents[next_idx]) as Texture2D

	turrent_prev.position = turrent_prev_pst
	turrent_cur.position = turrent_cur_pst
	turrent_next.position = turrent_next_pst
	
	Global.cur_turrent_idx = cur_turrent_idx
	Global.cur_turrent_path = turrents[cur_turrent_idx]
	Global.cur_turrent_spriteframes_path = turrent_spriteframes[cur_turrent_idx]

func save_data():
	#add persistance
	var data = {
		"turrent_path":Global.cur_turrent_path,
		"turrent_spriteframes":Global.cur_turrent_spriteframes_path,
		"turrent_idx":Global.cur_turrent_idx,
		"base_path":Global.cur_base_path,
		"base_mat_path": Global.cur_base_mat_path,
		"base_idx":Global.cur_base_idx
	}
	var file = FileAccess.open(Global.SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_data():
	if not FileAccess.file_exists(Global.SAVE_FILE):
		Global.cur_base_idx = 0
		Global.cur_base_path = bases[0]
		Global.cur_base_mat_path = base_mats[0]
		return
	
	var file = FileAccess.open(Global.SAVE_FILE,FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json_text)
	
	if data:
		cur_base_idx = wrap_idx(int(data.get("base_idx", 0)))
		cur_turrent_idx = wrap_idx(int(data.get("turrent_idx", 0)))

		Global.cur_base_idx = cur_base_idx
		Global.cur_base_path = bases[cur_base_idx]
		Global.cur_base_mat_path = base_mats[cur_base_idx]
		Global.cur_turrent_idx = cur_turrent_idx
		Global.cur_turrent_path = turrents[cur_turrent_idx]
		Global.cur_turrent_spriteframes_path = turrent_spriteframes[cur_turrent_idx]
	else:
		Global.cur_base_idx = 0
		Global.cur_base_path = bases[0]
		Global.cur_base_mat_path = base_mats[0]
		Global.cur_turrent_idx = 0
		Global.cur_turrent_path = turrents[0]
		Global.cur_turrent_spriteframes_path = turrent_spriteframes[0]

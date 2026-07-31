extends CanvasLayer

@onready var base = $Control/base
@onready var gun = $Control/gun

var turrents:Array = [
	"res://sprites/turrent/TURRENT_1_STORE.png",
	"res://sprites/turrent/TURRENT_2_STORE.png",
	"res://sprites/turrent/TURRENT_3_STORE.png"
]


func change_scene(scene: String) -> void:
	base.texture = load(Global.cur_base_path) as Texture2D
	base.material = load(Global.cur_base_mat_path) as Material
	gun.texture = load(turrents[Global.cur_turrent_idx]) as Texture2D
	$AnimationPlayer.play("Scene_transition_enter")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(scene)
	$AnimationPlayer.play("Scene_transition_exit")

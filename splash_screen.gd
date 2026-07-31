extends Control

@onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("fade_anim")

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

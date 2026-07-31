extends Node

var music: bool = true
var music_value: float = 1
var sfx: bool = true
var sfx_value: float = 1

#STORE RELATED VARIABLES
var cur_turrent_path:String
var cur_turrent_idx:int = 0
var cur_turrent_spriteframes_path:String = "res://sprites/turrent_spriteframes/turrent_1_spriteframes.tres"

var cur_base_path:String
var cur_base_idx:int = 0
var cur_base_mat_path:String = "res://shaders/base_mats/base_1_mat.tres"

const SAVE_FILE = "user://save_data.json"

#UPGRADES RELATED VARIABLES
const SAVE_PATH = "user://store_save.json"

var total_score:int = 0
var speed_boost:bool = false
var power_shot:bool = false
var multiply_score:bool = false
var luck_score:bool = false

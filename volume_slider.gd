extends HSlider

@export var bus_name:String
var bus_index:int

# Called when the node enters the scene tree for the first time.
func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	_set_slider()

func _on_value_changed(value: float):
	if bus_name == "Music": Global.music_value = value
	elif bus_name == "SFX": Global.sfx_value = value
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

#initalize slider
func _set_slider():
	if bus_name == "Music": value = Global.music_value
	elif bus_name == "SFX": value = Global.sfx_value

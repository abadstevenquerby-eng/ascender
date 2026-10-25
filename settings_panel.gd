extends Control
@onready var fullscreen_check: TextureButton = %CheckBox
@onready var master_slider: HSlider = %HSlider
@onready var music_slider: HSlider = %mslider
@onready var ambience_slider: HSlider = %aslider
@onready var sfx_slider: HSlider =  %sfxSlider
@onready var sfx_click: AudioStreamPlayer = %sfx_click
const SAVE_PATH = "user://save_game.json"
var window = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	if not FileAccess.file_exists(SAVE_PATH):
		master_slider.value = 0.8
		music_slider.value = 0.8
		ambience_slider.value = 0.8
		sfx_slider.value = 0.8
	else:
		_init_settings_values()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _init_settings_values() -> void:
	var data: Dictionary = {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var result = json.get_data()
		if result is Dictionary:
			data = result
	
	
	
	# Initialize Master Volume Slider
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1 and master_slider:
		var db = AudioServer.get_bus_volume_db(master_bus_idx)
		db = data["master"]
		master_slider.value = db

			
	# TODO (co-programmer): Replace "Music" with the actual bus name once it's created in the AudioServer.
	# Initialize Music Volume Slider
	var music_bus_idx = AudioServer.get_bus_index("music")
	if music_bus_idx != -1 and music_slider:
		var db = AudioServer.get_bus_volume_db(music_bus_idx)
		db = data["music"]
		music_slider.value = db

	
	# TODO (co-programmer): Replace "Ambience" with the actual bus name once it's created in the AudioServer.
	# Initialize Ambience Volume Slider
	var ambience_bus_idx = AudioServer.get_bus_index("ambience")
	if ambience_bus_idx != -1 and ambience_slider:
		var db = AudioServer.get_bus_volume_db(ambience_bus_idx)
		db = data["ambience"]  
		ambience_slider.value = db
	
	# TODO (co-programmer): Replace "SFX" with the actual bus name once it's created in the AudioServer.
	# Initialize SFX Volume Slider
	var sfx_bus_idx = AudioServer.get_bus_index("sfx")
	if sfx_bus_idx != -1 and sfx_slider:
		var db = AudioServer.get_bus_volume_db(sfx_bus_idx)
		db = data["sfx"]
		sfx_slider.value = db
	
	# Initialize Fullscreen Checkbox
	if fullscreen_check:
		if data["window"] == "full":
			fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif data["window"] == "minimize":
			fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
		
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()


func _on_h_slider_value_changed(value: float) -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))

# TODO (co-programmer): Wire this to the "Music" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "Music".
func _on_mslider_value_changed(value: float) -> void:
	var music_bus_idx = AudioServer.get_bus_index("music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))


# TODO (co-programmer): Wire this to the "Ambience" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "Ambience".
func _on_aslider_value_changed(value: float) -> void:
	var ambience_bus_idx = AudioServer.get_bus_index("ambience")
	if ambience_bus_idx != -1:
		AudioServer.set_bus_volume_db(ambience_bus_idx, linear_to_db(value))


# TODO (co-programmer): Wire this to the "SFX" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "SFX".
func _on_sfx_slider_value_changed(value: float) -> void:
	var sfx_bus_idx = AudioServer.get_bus_index("sfx")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))


func _on_check_box_toggled(toggled_on: bool) -> void:
	_play_click_sfx()
	if toggled_on:
		window = "full"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		window = "minimize"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _on_back_btn_pressed() -> void:
	sfx_click.play()
	var data: Dictionary = {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var result = json.get_data()
		if result is Dictionary:
			data = result
		data["master"] = master_slider.value
		data["music"] = music_slider.value
		data["ambience"] = ambience_slider.value
		data["sfx"] = sfx_slider.value
		data["window"] = window
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
	visible = false


# ------------------------------------------------------------------------------
# Audio Helper
# ------------------------------------------------------------------------------

func _play_click_sfx() -> void:
	if sfx_click:
		sfx_click.play()

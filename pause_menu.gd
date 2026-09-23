extends CanvasLayer

## Pause Menu Script
## Implements the Pause Menu system based on the team's flowchart:
## 1. Resume Game
## 2. Mechanic & Controls submenu -> End (Back)
## 3. Settings submenu -> End (Back)
## 4. Save Position -> Exit level (Returns to Level Selection / Menu)

@onready var main_pause_panel: Control = $Control/MainPausePanel
@onready var mechanics_panel: Control = $Control/MechanicsPanel
@onready var settings_panel: Control = $Control/SettingsPanel
@onready var master_slider: HSlider = $Control/SettingsPanel/VBoxContainer/MasterVolume/HSlider
@onready var music_slider: HSlider = $Control/SettingsPanel/VBoxContainer/MusicVolume/HSlider
@onready var ambience_slider: HSlider = $Control/SettingsPanel/VBoxContainer/AmbienceVolume/HSlider
@onready var sfx_slider: HSlider = $Control/SettingsPanel/VBoxContainer/SFXVolume/HSlider
@onready var fullscreen_check: CheckBox = $Control/SettingsPanel/VBoxContainer/Fullscreen/CheckBox
@onready var save_status_label: Label = $Control/MainPausePanel/SaveStatusLabel
@onready var sfx_click: AudioStreamPlayer = %sfx_click
var is_paused: bool = false
var camera: int

# Save file path
const SAVE_PATH = "user://save_game.json"

func _ready() -> void:
	# CanvasLayer and this node must continue running when the game tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Start hidden
	visible = false
	_show_main_menu()
	
	# Initialize settings UI state
	_init_settings_values()


func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause menu with Escape key (ui_cancel) or P key
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P):
		# If inside a submenu (Settings or Mechanics), pressing Escape returns to the main pause menu first
		if mechanics_panel.visible or settings_panel.visible:
			_show_main_menu()
			_play_click_sfx()
		else:
			toggle_pause()
		get_viewport().set_input_as_handled()


## Toggles the pause state
func toggle_pause() -> void:
	set_paused(!is_paused)


## Sets the pause state and controls tree pausing
func set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		_show_main_menu()


# ------------------------------------------------------------------------------
# Navigation / Flowchart Handlers
# ------------------------------------------------------------------------------

## Shows the main pause panel and hides sub-panels
func _show_main_menu() -> void:
	main_pause_panel.visible = true
	mechanics_panel.visible = false
	settings_panel.visible = false
	if save_status_label:
		save_status_label.text = ""


## Flowchart: [Resume] -> End Pause
func _on_resume_pressed() -> void:
	_play_click_sfx()
	set_paused(false)


## Restarts the current active level
func _on_restart_pressed() -> void:
	_play_click_sfx()
	# Always unpause the tree before reloading so physics & input resume immediately
	get_tree().paused = false
	get_tree().reload_current_scene()


## Flowchart: [View the mechanics?] -> Yes -> Mechanic and Controls
func _on_mechanics_pressed() -> void:
	_play_click_sfx()
	main_pause_panel.visible = false
	mechanics_panel.visible = true
	settings_panel.visible = false


## Flowchart: [Configure Settings?] -> Yes -> Settings
func _on_settings_pressed() -> void:
	_play_click_sfx()
	main_pause_panel.visible = false
	mechanics_panel.visible = false
	settings_panel.visible = true


## Flowchart: Mechanic / Settings [Back / End] -> Return to Menu
func _on_back_to_menu_pressed() -> void:
	_play_click_sfx()
	_show_main_menu()


## Flowchart: [Save Position] -> [Exit level] -> [B] (Level Selection / Title)
func _on_save_and_exit_pressed() -> void:
	_play_click_sfx()
	
	# Step 1: Save player position and current level
	save_current_position()
	
	if save_status_label:
		save_status_label.text = "Position Saved! Exiting..."
	
	# Small delay so the player can see the confirmation and hear the click
	await get_tree().create_timer(0.4, true, false, true).timeout
	
	# Step 2: Unpause tree before changing scene
	get_tree().paused = false
	
	# Step 3: Exit level (Return to level selection screen)
	get_tree().change_scene_to_file("res://level_selection.tscn")


# ------------------------------------------------------------------------------
# Save System Helper
# ------------------------------------------------------------------------------

## Saves the player's current position and scene path to a JSON file
func save_current_position() -> void:
	var player_node = _find_player_in_tree()
	var player_pos: Vector2 = Vector2.ZERO
	
	if player_node:
		player_pos = player_node.global_position
		print("[PauseMenu] Saved player position: ", player_pos)
	else:
		print("[PauseMenu] No player node found to save position, saving level progress.")
	
	var current_scene = ""
	if get_tree().current_scene:
		current_scene = get_tree().current_scene.name
	var save_data = {
			"level1": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1},
			"level2": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1},
			"level3": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1},
			"level4": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1}
		}
		
	var data: Dictionary = {}
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			var result = json.get_data()
			if result is Dictionary:
				data = result
		data[current_scene]["player_x"] = player_pos.x
		data[current_scene]["player_y"] = player_pos.y
		data[current_scene]["started"] = true
		data[current_scene]["camera"] = get_parent().current
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("[PauseMenu] Game successfully saved to ", SAVE_PATH)
	else:
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		save_data[current_scene]["player_x"] = player_pos.x
		save_data[current_scene]["player_y"] = player_pos.y
		save_data[current_scene]["started"] = true
		save_data[current_scene]["camera"] = camera
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("[PauseMenu] Game successfully saved to ", SAVE_PATH)

## Helper to locate the active player node in the current scene
func _find_player_in_tree() -> Node2D:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return null
	
	# Search common node names
	for node_name in ["player", "Player", "playerlvl1", "player_3"]:
		var found = current_scene.find_child(node_name, true, false)
		if found and found is Node2D:
			return found
			
	return null


# ------------------------------------------------------------------------------
# Settings Logic
# ------------------------------------------------------------------------------

func _init_settings_values() -> void:
	# Initialize Master Volume Slider
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1 and master_slider:
		var db = AudioServer.get_bus_volume_db(master_bus_idx)
		master_slider.value = db_to_linear(db)
	
	# TODO (co-programmer): Replace "Music" with the actual bus name once it's created in the AudioServer.
	# Initialize Music Volume Slider
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1 and music_slider:
		var db = AudioServer.get_bus_volume_db(music_bus_idx)
		music_slider.value = db_to_linear(db)
	else:
		if music_slider:
			music_slider.value = 0.8  # Default until bus is available
	
	# TODO (co-programmer): Replace "Ambience" with the actual bus name once it's created in the AudioServer.
	# Initialize Ambience Volume Slider
	var ambience_bus_idx = AudioServer.get_bus_index("Ambience")
	if ambience_bus_idx != -1 and ambience_slider:
		var db = AudioServer.get_bus_volume_db(ambience_bus_idx)
		ambience_slider.value = db_to_linear(db)
	else:
		if ambience_slider:
			ambience_slider.value = 0.8  # Default until bus is available
	
	# TODO (co-programmer): Replace "SFX" with the actual bus name once it's created in the AudioServer.
	# Initialize SFX Volume Slider
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1 and sfx_slider:
		var db = AudioServer.get_bus_volume_db(sfx_bus_idx)
		sfx_slider.value = db_to_linear(db)
	else:
		if sfx_slider:
			sfx_slider.value = 0.8  # Default until bus is available
	
	# Initialize Fullscreen Checkbox
	if fullscreen_check:
		fullscreen_check.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_master_volume_changed(value: float) -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if master_bus_idx != -1:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))


# TODO (co-programmer): Wire this to the "Music" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "Music".
func _on_music_volume_changed(value: float) -> void:
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))


# TODO (co-programmer): Wire this to the "Ambience" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "Ambience".
func _on_ambience_volume_changed(value: float) -> void:
	var ambience_bus_idx = AudioServer.get_bus_index("Ambience")
	if ambience_bus_idx != -1:
		AudioServer.set_bus_volume_db(ambience_bus_idx, linear_to_db(value))


# TODO (co-programmer): Wire this to the "SFX" audio bus once it exists in the AudioServer.
# Create the bus in: Project > Project Settings > Audio > Add Bus, name it "SFX".
func _on_sfx_volume_changed(value: float) -> void:
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	_play_click_sfx()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# ------------------------------------------------------------------------------
# Audio Helper
# ------------------------------------------------------------------------------

func _play_click_sfx() -> void:
	if sfx_click:
		sfx_click.play()

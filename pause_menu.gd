extends CanvasLayer

## Pause Menu Script
## Implements the Pause Menu system based on the team's flowchart:
## 1. Resume Game
## 2. Mechanic & Controls submenu -> End (Back)
## 3. Settings submenu -> End (Back)
## 4. Save Position -> Exit level (Returns to Level Selection / Menu)

@onready var settings_panel: Control = %SettingsPanel
@onready var sfx_click: AudioStreamPlayer = %sfx_click
@onready var main_pause_panel: Control = $Control/MainPausePanel
@onready var mechanics_panel: Control = $Control/MechanicsPanel
@onready var save_status_label: Label = $Control/MainPausePanel/SaveStatusLabel
@onready var minute: Label = %minute
@onready var seconds: Label = %seconds
@onready var microseconds: Label = %microseconds
var is_paused: bool = false
var camera: int
var finished = false
var starting_pos: Vector2
var restarted = false
var checkpointed = false
var time: float = 0.0
var mnute: int
var sec: int
var msec: int



# Save file path
const SAVE_PATH = "user://save_game.json"

func _process(delta) -> void:
	if is_paused == false:
		time += delta
		msec = fmod(time, 1) * 100
		sec = fmod(time, 60)
		mnute = fmod(time, 3600) /60
		minute.text = "%02d:" % mnute
		seconds.text = "%02d." % sec
		microseconds.text = "%03d" % msec
	else:
		pass
		
func _ready() -> void:
	# CanvasLayer and this node must continue running when the game tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
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
		time = data[get_tree().current_scene.name]["timer"]
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
	# Start hidden
	visible = false
	_show_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause menu with Escape key (ui_cancel) or P key
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P):
		# If inside a submenu (Settings or Mechanics), pressing Escape returns to the main pause menu first
		save_current_position() #Saves the current player position the moment the pause menu shows up
		if mechanics_panel.visible or settings_panel.visible:
			_show_main_menu()
			sfx_click.play()
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


## Flowchart: [Resume] -> End Pause
func _on_resume_pressed() -> void:
	sfx_click.play()
	set_paused(false)
	


## Restarts the current active level
func _on_restart_pressed() -> void:
	sfx_click.play()
	# 1. Loads the raw data straight from the file path
	var json_text = FileAccess.get_file_as_string(SAVE_PATH)
	
	# 2. Automatically parses it into a Dictionary or Array
	var data = JSON.parse_string(json_text)
	
	if data == null:
		print("Failed to parse JSON. Invalid format.")
	restarted = true
	save_current_position()
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass
	


## Flowchart: [View the mechanics?] -> Yes -> Mechanic and Controls
func _on_mechanics_pressed() -> void:
	sfx_click.play()
	main_pause_panel.visible = false
	mechanics_panel.visible = true
	settings_panel.visible = false


## Flowchart: [Configure Settings?] -> Yes -> Settings
func _on_settings_pressed() -> void:
	sfx_click.play()
	main_pause_panel.visible = true
	mechanics_panel.visible = false
	settings_panel.visible = true


## Flowchart: Mechanic / Settings [Back / End] -> Return to Menu
func _on_back_to_menu_pressed() -> void:
	sfx_click.play()
	_show_main_menu()


## Flowchart: [Save Position] -> [Exit level] -> [B] (Level Selection / Title)
func _on_save_and_exit_pressed() -> void:
	sfx_click.play()
	
	if save_status_label:
		save_status_label.text = "Exiting..."
	
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
	
	if save_status_label:
		save_status_label.text = "Position saved"
	
	if player_node:
		player_pos = player_node.position
		print("[PauseMenu] Saved player position: ", player_pos)
	else:
		print("[PauseMenu] No player node found to save position, saving level progress.")
	
	var current_scene = ""
	if get_tree().current_scene:
		current_scene = get_tree().current_scene.name

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
		if finished == true:
			data[current_scene]["finished"] = finished
			data[current_scene]["player_x"] = starting_pos.x
			data[current_scene]["player_y"] = starting_pos.y
			data[current_scene]["camera"] = 1
			data[current_scene]["started"] = false
			data[current_scene]["checkpoint_x"] = starting_pos.x
			data[current_scene]["checkpoint_y"] = starting_pos.y
			data[current_scene]["checkpoint_cam"] = 1
		else:
			data[current_scene]["player_y"] = player_pos.y
			data[current_scene]["player_x"] = player_pos.x
			data[current_scene]["camera"] = get_parent().current
			if restarted and data[current_scene]["checkpoint_x"] != 0:
				data[current_scene]["player_x"] = data[current_scene]["checkpoint_x"]
				data[current_scene]["player_y"] = data[current_scene]["checkpoint_y"]
				data[current_scene]["camera"] = data[current_scene]["checkpoint_cam"]
			if restarted and data[current_scene]["checkpoint_x"] == 0: # might be a bit reduntant and uneeded
				print(starting_pos)
				data[current_scene]["player_x"] = starting_pos.x
				data[current_scene]["player_y"] = starting_pos.y
				data[current_scene]["camera"] = data[current_scene]["checkpoint_cam"]
			elif checkpointed:
				data[current_scene]["checkpoint_x"] = player_pos.x
				data[current_scene]["checkpoint_y"] = player_pos.y
				data[current_scene]["checkpoint_cam"] = data[current_scene]["camera"]
				checkpointed = false
			data[current_scene]["timer"] = time
			data[current_scene]["started"] = true
			
		
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
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

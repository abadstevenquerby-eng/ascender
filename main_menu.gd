extends Node2D
@onready var pressed: AudioStreamPlayer = %pressed
@onready var on_press: AudioStreamPlayer = %on_press
var clicked = false
@onready var pause_menu: CanvasLayer = %PauseMenu
const SAVE_PATH = "user://save_game.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		create_json()
	else:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quit_button_down() -> void:
	on_press.play()

func _on_quit_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	pause_menu.visible = true


func _on_start_game_button_down() -> void:
	on_press.play()


func _on_start_game_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://level_selection.tscn")
	
func create_json() -> void:
	var save_data = {
			"level1": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1,
			"finished": false,
			"path2d": 0, #all path2d not currently used
			"checkpoint_x" : 0,
			"checkpoint_y" : 0},
			"level2": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1,
			"finished": false,
			"path2d": 0,
			"checkpoint_x" : 0,
			"checkpoint_y" : 0},
			"level3": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1,
			"finished": false,
			"path2d": 0,
			"checkpoint_x" : 0,
			"checkpoint_y" : 0},
			"level4": {
			"player_x": 0,
			"player_y": 0,
			"started": false,
			"camera": 1,
			"finished": false,
			"path2d": 0,
			"checkpoint_x" : 0,
			"checkpoint_y" : 0}
		}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

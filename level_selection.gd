extends Node2D
@onready var sfx_click: AudioStreamPlayer = %sfx_click
const SAVE_PATH = "user://save_game.json"
var data = load_json_file(SAVE_PATH)
@onready var label: Label = %Label
@onready var level_2: Button = %Level2
@onready var level_3: Button = %Level3
@onready var level_4: Button = %"Level 4"
@onready var lock: Sprite2D = %Lock
@onready var lock_2: Sprite2D = %Lock2
@onready var lock_3: Sprite2D = %Lock3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conditions()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level 1/level1.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_2/level2.tscn")

func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_3/level3.tscn")

func _on_level_4_pressed() -> void:
	level_3.disabled


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func load_json_file(SAVE_PATH: String) -> Variant:
	if not FileAccess.file_exists(SAVE_PATH):
		print("File does not exist: ", SAVE_PATH)
		return null
		
	# 1. Read the file as a string
	var json_as_text = FileAccess.get_file_as_string(SAVE_PATH)
	
	# 2. Parse the string into a Godot Variant (Dictionary or Array)
	var parsed_data = JSON.parse_string(json_as_text)
	
	if parsed_data == null:
		print("Failed to parse JSON or file is empty.")
		return null
	return parsed_data

func conditions() -> void:
	if data and data["level1"]["finished"] == true:
		level_2.disabled = false
	else:
		level_2.disabled = true
	if data and data["level2"]["finished"] == true:
		level_3.disabled = false
	else:
		level_3.disabled = true
	if data and data["level3"]["finished"] == true:
		level_4.disabled = false
	else:
		level_4.disabled = true
	

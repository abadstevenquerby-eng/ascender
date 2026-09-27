extends Node2D
@onready var sfx_click: AudioStreamPlayer = $sfx_click
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
	if data and data["level1"]["finished"] == true:
		get_tree().change_scene_to_file("res://levels/level_2/level2.tscn")
	else:
		label.text = "Finish level 1, to play level 2"
		await get_tree().create_timer(2.0).timeout
		label.text = ""
	

func _on_level_3_pressed() -> void:
	if data and data["level2"]["finished"] == true:
		get_tree().change_scene_to_file("res://levels/level_3/level3.tscn")
	else:
		label.text = "Finish level 2, to play level 3"
		await get_tree().create_timer(2.0).timeout
		label.text = ""

func _on_level_4_pressed() -> void:
	if data and data["level3"]["finished"] == true:
		get_tree().change_scene_to_file("res://levels/level_3/level3.tscn")
	else:
		label.text = "Finish level 3, to play level 4"
		await get_tree().create_timer(2.0).timeout
		label.text = ""


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
		lock.visible = false
	else:
		lock.visible = true
	if data and data["level2"]["finished"] == true:
		lock_2.visible = false
	else:
		lock_2.visible = true
	if data and data["level3"]["finished"] == true:
		lock_3.visible = false
	else:
		lock_3.visible = true
	

extends Node2D
@onready var camera_2: Camera2D = %camera2
@onready var camera_3: Camera2D = %camera3
@onready var camera_1: Camera2D = %camera1
@onready var camera_4: Camera2D = %camera4
@onready var camera_5: Camera2D = %camera5
@onready var player: CharacterBody2D = %player

const SAVE_PATH = "user://save_game.json"

var current = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()
	cam(current)
	set_up_superjump()
	var data = load_json_file(SAVE_PATH)
	if data and data[get_tree().current_scene.name]["started"] == true:
		player.position.x = data[get_tree().current_scene.name]["player_x"]
		player.position.y = data[get_tree().current_scene.name]["player_y"]
		current = data[get_tree().current_scene.name]["camera"]
		cam(current)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func stop() -> void:
	MainAudio.stop()

func _on_switch_cam_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 1
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_2_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		$PauseMenu.camera = current
		cam(current)
		
func _on_switch_cam_3_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_3_reentry_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_4_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		$PauseMenu.camera = current
		cam(current)
		
func _on_switch_cam_4_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_5_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 5
		$PauseMenu.camera = current
		cam(current)

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name =="player":
		get_tree().change_scene_to_file("res://level_selection.tscn")

func cam(int) -> void:
	if current == 1:
		camera_1.make_current()
	elif current == 2:
		camera_2.make_current()
	elif current == 3:
		camera_3.make_current()
	elif current == 4:
		camera_4.make_current()
	elif current == 5:
		camera_5.make_current()

#Connects mushrooms for superjump
func set_up_superjump() -> void:
	var mushrooms = get_node_or_null("bouncing_mushroom")
	if mushrooms:
		for mushroom in mushrooms.get_children():
			mushroom.super_jump.connect(super_jumped)

func super_jumped(body):
	body.bounce()

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

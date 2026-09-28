extends Node2D
@onready var camera_2: Camera2D = %camera2
@onready var camera_3: Camera2D = %camera3
@onready var camera_1: Camera2D = %camera1
@onready var camera_4: Camera2D = %camera4
@onready var camera_5: Camera2D = %camera5
@onready var pause_menu: CanvasLayer = %PauseMenu
@onready var player: CharacterBody2D = %player
@onready var heightmeter: ProgressBar = %heightmeter
@onready var exit: Area2D = %exit


var data = load_json_file(SAVE_PATH)
var current = 1
var checkpoint: Vector2
var checkpointed= false
const SAVE_PATH = "user://save_game.json"
var bar_temporary: float
var player_temporary: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()

	heightmeter.max_value = abs(exit.position.y - 1189)
	heightmeter.min_value = 0
	if data and data[get_tree().current_scene.name]["started"] == true:
		print("undefaulted")
		player.position.x = data[get_tree().current_scene.name]["player_x"]
		player.position.y = data[get_tree().current_scene.name]["player_y"]
		current = data[get_tree().current_scene.name]["camera"]
		cam(current)
	else:
		cam(current)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.position.y > 0:
		heightmeter.value = player.position.y
		player_temporary = bar_temporary
	else:
		heightmeter.value = abs(player.position.y) + bar_temporary
	if checkpointed:
		$PauseMenu.checkpointed = true
		$PauseMenu.save_current_position()
		checkpointed = false
	
	
func stop() -> void:
	MainAudio.stop()

func _on_switch_cam_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 1
		heightmeter.position = Vector2(5, 39)
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		heightmeter.position = Vector2(5, -1196)
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_2_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		heightmeter.position = Vector2(5, -1196)
		$PauseMenu.camera = current
		cam(current)
		
func _on_switch_cam_3_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		heightmeter.position = Vector2(5, -2461)
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_3_reentry_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		heightmeter.position = Vector2(5, -2461)
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_4_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		heightmeter.position = Vector2(5, -3650)
		$PauseMenu.camera = current
		cam(current)
		
func _on_switch_cam_4_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		heightmeter.position = Vector2(5, -3650)
		$PauseMenu.camera = current
		cam(current)

func _on_switch_cam_5_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 5
		heightmeter.position = Vector2(5, -4936)
		$PauseMenu.camera = current
		cam(current)

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "player":
		await get_tree().create_timer(2).timeout
		$PauseMenu.finished = true
		$PauseMenu.starting_pos = Vector2(154, 1176)
		$PauseMenu.save_current_position()
		get_tree().change_scene_to_file("res://level_selection.tscn")

func cam(current: int) -> void:
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
		
func load_json_file(Path: String) -> Variant:
	if not FileAccess.file_exists(Path):
		print("File does not exist: ", Path)
		return null
		
	#Used to read the file as a string
	var json_as_text = FileAccess.get_file_as_string(Path)
	
	# 2. Parse the string into a dictionary
	var parsed_data = JSON.parse_string(json_as_text)
	
	if parsed_data == null:
		print("Failed to parse JSON or file is empty.")
		return null
	return parsed_data

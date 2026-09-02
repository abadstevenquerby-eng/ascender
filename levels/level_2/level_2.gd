extends Node2D
@onready var camera_2: Camera2D = %camera2
@onready var camera_3: Camera2D = %camera3
@onready var camera_1: Camera2D = %camera1
@onready var camera_4: Camera2D = %camera4
@onready var camera_5: Camera2D = %camera5

var current = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()
	cam(current)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func stop() -> void:
	MainAudio.stop()

func _on_switch_cam_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 1
		cam(current)

func _on_switch_cam_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		cam(current)

func _on_switch_cam_2_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 2
		cam(current)
		
func _on_switch_cam_3_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		cam(current)

func _on_switch_cam_3_reentry_2_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 3
		cam(current)

func _on_switch_cam_4_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		cam(current)
		
func _on_switch_cam_4_reentry_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 4
		cam(current)

func _on_switch_cam_5_body_entered(body: Node2D) -> void:
	if body.name == "player":
		current = 5
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

extends Node2D
@onready var pressed: AudioStreamPlayer = %pressed
@onready var on_press: AudioStreamPlayer = %on_press
var clicked = false
@onready var confirmation: CanvasLayer = %confirmation
@onready var start: CanvasLayer = %start
const SAVE_PATH = "user://save_game.json"
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var settings: Control  = %settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		start.visible = true
	else:
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_quit_button_down() -> void:
	on_press.play()

func _on_quit_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	confirmation.visible = true


func _on_start_game_button_down() -> void:
	on_press.play()


func _on_start_game_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://level_selection.tscn")
	


func _on_settings_pressed() -> void:
	settings.visible = true
	


func _on_leaderboards_pressed() -> void:
	get_tree().change_scene_to_file("res://addons/silent_wolf/Scores/Leaderboard.tscn")

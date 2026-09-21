extends Node2D
@onready var pressed: AudioStreamPlayer = %pressed
@onready var on_press: AudioStreamPlayer = %on_press
var clicked = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_quit_button_down() -> void:
	on_press.play()

func _on_quit_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_start_game_button_down() -> void:
	on_press.play()


func _on_start_game_button_up() -> void:
	pressed.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://level_selection.tscn")

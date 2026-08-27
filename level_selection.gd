extends Node2D
@onready var sfx_click: AudioStreamPlayer = $sfx_click


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_pressed() -> void:
	$sfx_click.play()
	get_tree().change_scene_to_file("res://levels/level 1/level1.tscn")


func _on_level_2_pressed() -> void:
	$sfx_click.play()
	await get_tree
	get_tree().change_scene_to_file("res://levels/testlevel/testmushroom.tscn")

extends CanvasLayer
@onready var sfx_click: AudioStreamPlayer = %sfx_click


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_yes_pressed() -> void:
	sfx_click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_no_pressed() -> void:
	sfx_click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")

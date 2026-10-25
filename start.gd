extends CanvasLayer
const SAVE_PATH = "user://save_game.json"
@onready var input: LineEdit = %input
@onready var sfx_click: AudioStreamPlayer = %sfx_click

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_submit_pressed() -> void:
	sfx_click.play()
	await get_tree().create_timer(0.5).timeout
	create_json()
	visible = false


func create_json() -> void:
	var user_input = input.text
	var save_data = {
			"player": user_input,
			"master": 0.8,
			"music": 0.8,
			"ambience": 0.8,
			"sfx": 0.8,
			"window": "full",
			"level1": {
				"player_x": 0,
				"player_y": 0,
				"started": false,
				"camera": 1,
				"finished": false,
				"path2d": 0,
				"checkpoint_x" : 154,
				"checkpoint_y" : 1176,
				"checkpoint_cam": 1,
				"timer": 0},
			"level2": {
				"player_x": 0,
				"player_y": 0,
				"started": false,
				"camera": 1,
				"finished": false,
				"path2d": 0,
				"checkpoint_x" : 61,
				"checkpoint_y" : 1186,
				"checkpoint_cam": 1,
				"timer": 0},
			"level3": {
				"player_x": 0,
				"player_y": 0,
				"started": false,
				"camera": 1,
				"finished": false,
				"path2d": 0,
				"checkpoint_x" : 75,
				"checkpoint_y" : 1141,
				"checkpoint_cam": 1,
				"timer": 0},
			"level4": {
				"player_x": 0,
				"player_y": 0,
				"started": false,
				"camera": 1,
				"finished": false,
				"path2d": 0,
				"checkpoint_x" : 0,
				"checkpoint_y" : 0,
				"checkpoint_cam": 1,
				"timer": 0}
			}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()

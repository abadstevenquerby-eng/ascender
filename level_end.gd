extends CanvasLayer
const SAVE_PATH = "user://save_game.json"
var time: float
var mnute: int
var sec: int
var msec: int
var temp: String
@onready var minute: Label = %minute
@onready var seconds: Label = %seconds
@onready var microseconds: Label = %microseconds
@onready var confirmation: Panel = %Confirmation
@onready var yes: Button = %Yes
@onready var no: Button = %No
@onready var main_pause_panel: Panel = %MainPausePanel
@onready var sfx_click: AudioStreamPlayer = %sfx_click

func _ready() -> void:
	confirmation.visible = false
	var data: Dictionary = {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var result = json.get_data()
		if result is Dictionary:
			data = result
		time = data[get_tree().current_scene.name]["timer"]
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().paused == false:
		time += delta
		msec = fmod(time, 1) * 100
		sec = fmod(time, 60)
		mnute = fmod(time, 3600) /60
		
		
	else:
		minute.text = "%02d:" % mnute
		seconds.text = "%02d." % sec
		microseconds.text = "%03d" % msec


func _on_nextlvl_pressed() -> void:
	sfx_click.play()
	temp = "next"
	main_pause_panel.visible = false
	confirmation.visible = true


func _on_restlvl_pressed() -> void:
	sfx_click.play()
	temp = "rest"
	main_pause_panel.visible = false
	confirmation.visible = true


func _on_exit_pressed() -> void:
	sfx_click.play()
	confirmation.visible = true
	main_pause_panel.visible = false
	temp = "exit"
	


func _on_yes_pressed() -> void:
	sfx_click.play()
	var data: Dictionary = {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var result = json.get_data()
		if result is Dictionary:
			data = result
		if get_tree().current_scene.name == "level1":
			SilentWolf.Scores.save_score(data["player"], (data[get_tree().current_scene.name]["timer"] * -1))
		else:
			print(get_tree().current_scene.name)
			SilentWolf.Scores.save_score(data["player"], (data[get_tree().current_scene.name]["timer"] * -1), get_tree().current_scene.name)
		data[get_tree().current_scene.name]["timer"] = 0
		file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
	if temp == "next":
		get_tree().paused = false
		if get_tree().current_scene.name == "level1":
			get_tree().change_scene_to_file("res://levels/level_2/level2.tscn")
		elif get_tree().current_scene.name == "level2":
			get_tree().change_scene_to_file("res://levels/level_3/level3.tscn")
		else:
			get_tree().change_scene_to_file("res://level_selection.tscn")
	elif temp == "rest":
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif temp == "exit":
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	


func _on_no_pressed() -> void:
	sfx_click.play()
	if temp == "next":
		get_tree().paused = false
		if get_tree().current_scene.name == "level1":
			get_tree().change_scene_to_file("res://levels/level_2/level2.tscn")
		elif get_tree().current_scene.name == "level2":
			get_tree().change_scene_to_file("res://levels/level_3/level3.tscn")
		else:
			get_tree().change_scene_to_file("res://level_selection.tscn")
	elif temp == "rest":
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif temp == "exit":
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")

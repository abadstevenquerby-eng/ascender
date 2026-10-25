extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  SilentWolf.configure({
	"api_key": "UdPLlL0rM74aeyq2BmsC76AA6QPYyDLq61wSGktm",
	"game_id": "TheAscender",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://main_menu.tscn"
  })

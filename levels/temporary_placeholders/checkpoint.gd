extends Area2D
const SAVE_PATH = "user://save_game.json"
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var label: Label = %Label
var camera: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		get_parent().get_parent().checkpoint = collision_shape_2d.global_position
		get_parent().get_parent().checkpointed = true
		camera = get_parent().get_parent().current
		label.text = "Checkpoint saved!"
		await get_tree().create_timer(2).timeout
		label.text = ""

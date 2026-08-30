extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
var fall = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enter(body: Node2D) -> void:
	if body.name == "player" and !fall:
		print()
		var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		var post_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		
		opacity_tween.tween_property(self, "modulate:a", 0.0, 1.5)
		post_tween.tween_property(self, "global_position", global_position+Vector2(0,20), 2.5)
		post_tween.finished.connect(uncollide)
		fall = true
	

func uncollide():
	collision_shape_2d.disabled = true
	await get_tree().create_timer(2.0).timeout
	appear()
	
func appear():
	var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	var post_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	opacity_tween.tween_property(self, "modulate:a", 1.0, 2)
	post_tween.tween_property(self, "global_position", global_position+Vector2(0,-20), 2)
	collision_shape_2d.disabled = false
	fall = false

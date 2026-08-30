extends Path2D

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

var speed = 0.2
var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	path_follow_2d.progress_ratio += speed * delta * direction
	
	if direction == 1 and path_follow_2d.progress_ratio == 1:
		direction = -1
	elif direction == -1 and path_follow_2d.progress_ratio == 0:
		direction = 1

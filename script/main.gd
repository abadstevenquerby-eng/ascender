extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_superjump()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#Connects mushrooms for superjump
func set_up_superjump() -> void:
	var mushrooms = $testmushroom.get_node_or_null("bouncing_mushroom")
	if mushrooms:
		for mushroom in mushrooms.get_children():
			mushroom.super_jump.connect(super_jumped)
			


func super_jumped(body):
	print("bounced")
	body.bounce()

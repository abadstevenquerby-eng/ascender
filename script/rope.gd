@tool
extends Area2D

@onready var rope: Area2D = $"."

signal onRope
var maxSwing =  45 #Defines how wide the swing will be
var direction = -0.5 #Value used to make the vine move

@export var ropeTexture: CompressedTexture2D:
	set(newValue):
		ropeTexture = newValue

@export var length = 1:
	set(newValue):
		if newValue < 0: return
		
		length = newValue
		
		_delete_all_sprite_nodes()
		_create_rope()

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	_set_collision()

func _delete_all_sprite_nodes():
	for child in get_children():
		if child is Sprite2D: child. queue_free()
		
func _create_rope():
	for i in length:
		var ropeNode = Sprite2D.new()
		ropeNode.texture = ropeTexture
		
		add_child(ropeNode)
		ropeNode.position.y = i * 175
		
func _set_collision():
	var textureSize = ropeTexture.get_size()
	var fullLength = textureSize.y * length
	collision_shape_2d.shape.size.y = fullLength
	collision_shape_2d.position.y = fullLength / 2 - textureSize.y / 2

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		emit_signal("onRope", rope, body)

func  _process(delta: float) -> void:
	rotation_degrees += direction
	if rotation_degrees >= 0 + maxSwing:
		direction = -0.5
	elif rotation_degrees <= 0 - maxSwing:
		direction = 0.5

#Is called by the player script in order to latch onto the moving rope
func get_rope_position(body):
	var newPosition
	var shortestDistance
	
	for child in get_children(): #Checks the rope group to find the global position of the 
		if not child is Sprite2D: continue
		var distance =  body.global_position.distance_to(child.global_position)
		
		if not shortestDistance or distance < shortestDistance:
			newPosition = child.global_position
			shortestDistance = distance
		return newPosition

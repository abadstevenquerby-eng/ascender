extends CharacterBody2D

#The variable accessing the animations in animatedsprite2d
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#Games states
enum State{
	Fall,
	Floor,
	Jump,
	Wall_Jump,
	Swing
}

#Variables
const fall_gravity = 1500.0
const fall_velocity = 500.0
const walk_velocity = 200.0
const jump_velocity = -600.0
const jump_deceleration = 1500.0
var jump_x = 0

#Default state is fall for now, might change it to floor one day
var active_state := State.Fall

#Prepares the starting state
func _ready() -> void:
	switch_state(active_state)

func hold():
		animated_sprite_2d.animation = "hold"
	
		
	
func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

#Used to switch and match states
func switch_state(to_state: State) -> void:
	active_state = to_state
	
	match active_state:
		State.Fall:
			animated_sprite_2d.animation = "fall"
	
		State.Jump:
			animated_sprite_2d.animation = "jump"
			velocity.y = jump_velocity



#Defines what each states does.
func process_state(delta: float) -> void:
	match active_state:
		State.Fall:
			velocity.y = move_toward(velocity.y, fall_velocity, fall_gravity * delta)
			velocity.x = 0
			if is_on_floor():
				switch_state(State.Floor)
				
		State.Floor:
			if Input.get_axis("left", "right"):
				animated_sprite_2d.animation = "run"
			else:
				animated_sprite_2d.animation = "idle"
			movement()
			if not is_on_floor():
				switch_state(State.Fall)
			elif Input.is_action_pressed("jump"):
				hold()
			elif Input.is_action_just_released("jump"):
					switch_state(State.Jump)
#In progress
		State.Jump:
			velocity.x = 0
			velocity.y = move_toward(velocity.y, 0, jump_deceleration * delta )
			velocity.x = move_toward(velocity.x, jump_x, jump_deceleration * delta)
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				jump_x = 100
				switch_state(State.Fall)

#Defines movement and direction of jumps 
func movement() -> void:
	var direction := Input.get_axis("left","right")
	if direction:
		animated_sprite_2d.flip_h = direction < 0
	velocity.x = direction * walk_velocity
	if animated_sprite_2d.flip_h == true:
		jump_x = -50
	else:
		jump_x = 50

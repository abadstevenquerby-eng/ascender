extends CharacterBody2D

#The variable accessing the animations in animatedsprite2d
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_slide: RayCast2D = %wall_slide



#Games states
enum State{
	Fall,
	Floor,
	Jump,
	Wall_Jump,
	Slide,
	Swing
}

#Variables
const fall_gravity = 1500.0
const fall_velocity = 500.0
const walk_velocity = 200.0
const jump_velocity = -600.0
const jump_deceleration = 1500.0
const increment = 250 #multiplier for jump force
const max_y = -1000.0 #maximum vertical jump
const max_x = 1000.0 #maximum horizontal jump
const wall_gravity = 300.0 #Used to calculate how fast the player slides
const wall_velocity = 500.0 #Maximum slide speed
var current_x:float = 0.0 #initial variable for jumping horizontally
var can_move = true #variable for when character can move or not
var flipped = false #variable for changing the horizontal value when changing directions
var current_y:float =  0.0 #Initial jump force




#Default state is fall for now, might change it to floor one day
var active_state := State.Fall

#Prepares the starting state
func _ready() -> void:
	switch_state(active_state)


#Is used to process physics inside the different states
func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()
	if Input.is_action_pressed("jump") and animated_sprite_2d.animation == "idle":
		can_move = false #prohibits movement while charging jump
		if flipped == false: #if flipped uses negative horizontal values otherwise use positive values for default
			current_x = move_toward(current_x, max_x , increment *delta)
		else:
			current_x= move_toward(current_x, max_y, increment * delta)
		current_y= move_toward(current_y, max_y, increment * delta)
		animated_sprite_2d.animation = "hold"

#Used because states change the value for everyframe and will get stuck if this part is inside the state
func jump_process() -> void:
		current_y = 0
		if flipped == true:
			current_x = -1
		else:
			current_x = 1
		
	
#Used to switch and match states
func switch_state(to_state: State) -> void:
	active_state = to_state
	
	match active_state:
		State.Fall:
			animated_sprite_2d.animation = "fall"
	
		State.Jump:
			animated_sprite_2d.animation = "jump"
		
		State.Slide:
			animated_sprite_2d.animation = "wall climb"
			velocity.y = 0


#Defines what each states does.
func process_state(delta: float) -> void:
	match active_state:
		State.Fall:
			velocity.y = move_toward(velocity.y, fall_velocity, fall_gravity * delta)
			if is_on_floor():
				switch_state(State.Floor)
			elif can_slide():
				print("can slide")
				switch_state(State.Slide)
			
		State.Floor:
			if Input.get_axis("left", "right") and can_move == true:
				animated_sprite_2d.animation = "run"
			else:
				animated_sprite_2d.animation = "idle"
			if can_move == true:
				movement()
			if not is_on_floor():
				switch_state(State.Fall)
			elif Input.is_action_just_released("jump"):
				can_move = true
				switch_state(State.Jump)

		State.Jump:
			velocity.x = current_x
			velocity.y = current_y
			jump_process()
			if velocity.y <= 0 or velocity.y >= 0:
				switch_state(State.Fall)
#In progress
		State.Slide:
			velocity.y = move_toward(velocity.y, wall_velocity, wall_gravity * delta)
			movement()
			if is_on_floor():
				switch_state(State.Floor)
			elif not can_slide():
				switch_state(State.Fall)


#Defines movement and direction of jumps 
func movement() -> void:
	var direction := (Input.get_axis("left","right"))
	if direction:
		animated_sprite_2d.flip_h = direction < 0
		#Forces the raycast to change directions
		wall_slide.position.x = direction * absf(wall_slide.position.x)
		wall_slide.target_position.x = direction * absf(wall_slide.target_position.x)
		wall_slide.force_raycast_update()
	velocity.x = direction * walk_velocity #Allows walking
	if animated_sprite_2d.flip_h == true: #changes the values used for jumping horizontally when the image gets flipped
		flipped = true
	else:
		flipped = false
		

func can_slide() -> bool: #used for wall sliding
	return is_on_wall_only() and wall_slide.is_colliding()

extends CharacterBody2D

#The variable accessing the animations in animatedsprite2d
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_slide: RayCast2D = %wall_slide
@onready var ledge: RayCast2D = %ledge
@onready var space: RayCast2D = %space
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var charge_bar: ProgressBar = get_node_or_null("%Chargebar")
@onready var sfx_jump: AudioStreamPlayer = %sfx_jump


#Games states
enum State{
	Fall,
	Floor,
	Jump,
	Wall_Jump,
	Slide,
	Swing,
	Climb
}

#Variables
const fall_gravity = 1000.0
const fall_velocity = 500.0
const walk_velocity = 300.0 #Used to dictate how fast the player moves
const increment = 400 #multiplier for jump force
const max_y = -500.0 #maximum vertical jump
const max_x = 500.0 #maximum horizontal jump
const wall_gravity = 200.0 #Used to calculate how fast the player slides
const wall_velocity = 500.0 #Maximum slide speed
var current_x:float = 0.0 #initial variable for jumping horizontally
var can_move = true #variable for when character can move or not
var flipped = false #variable for changing the horizontal value when changing directions
var onRope = false #Used for indicating rope state status
var current_y:float =  0.0 #Initial jump force
var bounce_multiplier = 0 #Used for super bounce calculation 
var facing_direction = 1.0 #Used for forcing player sprite to change direction depending on input
var climb_direction = 0 #Used for climbing up and down on the rope
var climb = true




#Default state is fall for now, might change it to floor one day
var active_state = State.Fall

#Prepares the starting state
func _ready() -> void:
	switch_state(active_state)
	ledge.add_exception(self)
	_setup_charge_bar()

#Is used to process physics inside the different states
func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()
	var is_charging = false
	if Input.is_action_pressed("jump") and animated_sprite_2d.animation == "stand":
		can_move = false #prohibits movement while charging jump
		if flipped == false: #if flipped uses negative horizontal values otherwise use positive values for default
			current_x = move_toward(current_x, max_x , increment *delta)
		else:
			current_x= move_toward(current_x, max_y, increment * delta)
		current_y= move_toward(current_y, max_y, increment * delta)
		animated_sprite_2d.offset = Vector2(0, 34 )
		animated_sprite_2d.animation = "hold"
	elif Input.is_action_pressed("jump") and animated_sprite_2d.animation == "wall climb":
		if flipped == true: #if flipped uses negative horizontal values otherwise use positive values for default
			current_x = move_toward(current_x, max_x , increment *delta)
		else:
			current_x= move_toward(current_x, max_y, increment * delta)
		current_y= move_toward(current_y, max_y, increment * delta)
	elif Input.is_action_pressed("jump") and animated_sprite_2d.animation == "swing":
		if flipped == false: #if flipped uses negative horizontal values otherwise use positive values for default
			current_x = move_toward(current_x, max_x , increment *delta)
		else:
			current_x= move_toward(current_x, max_y, increment * delta)
		current_y= move_toward(current_y, max_y, increment * delta)
	is_charging = true
	_update_charge_bar(is_charging)
	

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

		State.Climb:
			animated_sprite_2d.play("ledge climb") #work in progress (no sprite yet)
			velocity = Vector2.ZERO
			global_position.y = ledge.get_collision_point().y
			
		State.Swing:
			animated_sprite_2d.animation = "swing"
			rotation_degrees = 0
			velocity = Vector2.ZERO

#Defines what each states does.
func process_state(delta: float) -> void:
	match active_state:
		State.Fall:
			velocity.y = move_toward(velocity.y, fall_velocity, fall_gravity * delta)
			if is_on_floor():
				switch_state(State.Floor)
			elif can_slide():
				switch_state(State.Slide)
			elif is_input_facing() and is_ledge() and is_space():
				switch_state(State.Climb)
			elif onRope == true:
				switch_state(State.Swing)

		State.Floor:
			if Input.get_axis("left", "right") and can_move == true:
				animated_sprite_2d.animation = "run"
			else:
				
				animated_sprite_2d.animation = "stand"
			if can_move == true:
				movement()
			if not is_on_floor() and can_slide() == false: #Do not turn into elif
				switch_state(State.Fall)
			elif Input.is_action_just_released("jump"):
				can_move = true
				switch_state(State.Jump)
			elif onRope == true:
				switch_state(State.Swing)

		State.Jump:
			sfx_jump.play()
			animated_sprite_2d.offset = Vector2(0, 0)
			velocity.x = current_x 
			velocity.y = current_y -100
			jump_process()
			if velocity.y <= 0 and onRope == false or velocity.y >= 0 and onRope == false:
				switch_state(State.Fall)
			if not is_on_floor() and can_slide() == true: #Do not turn into elif
				switch_state(State.Slide)

#In progress: sprite needs to be changed at some point
		State.Slide:
			velocity.y = move_toward(velocity.y, wall_velocity, wall_gravity * delta)
			if is_on_floor():
				switch_state(State.Floor)
			elif not can_slide():
				switch_state(State.Fall)
			elif Input.is_action_just_pressed("jump"):
				set_facing_direction(-facing_direction)
				switch_state(State.Wall_Jump)
			elif Input.is_action_pressed("left"): #Allows players to adjust their position on the wall
				velocity.y = facing_direction * 75
			elif Input.is_action_pressed("right"):
				velocity.y = -facing_direction * 75
			elif is_input_facing() and is_ledge() and is_space():
				switch_state(State.Climb)

		State.Wall_Jump:
			velocity.y = 0
			if animated_sprite_2d.flip_h != true: #changes the values used for jumping horizontally when the image gets flipped
				flipped = true
			else:
				flipped = false
			if Input.is_action_just_released("jump"):
				bounce_multiplier = current_y
				switch_state(State.Jump)
				can_move = true

		State.Climb:
			if not animated_sprite_2d.is_playing(): #ensures the animation is over before changing the character position
				var offset = ledge_offset()
				offset.x *= facing_direction
				global_position += offset *2
				switch_state(State.Floor)
			
		State.Swing:
			if Input.is_action_pressed("up"):
				if facing_direction > 0:
					position.y += -facing_direction * 5
				else:
					position.y += facing_direction
			elif Input.is_action_pressed("down"):
				if facing_direction > 0:
					position.y += facing_direction * 5
				else:
					position.y += -facing_direction * 5
			movement()
			if Input.is_action_just_released("jump"):
				exit_rope()
				switch_state(State.Jump)
				

#Defines movement and direction of jumps (lacking sprites)
func movement(direction: = 0) -> void:
	if direction == 0:
		direction = (Input.get_axis("left","right"))
		
	set_facing_direction(direction)
	if not onRope:
		velocity.x = direction * walk_velocity #Allows walking
	if animated_sprite_2d.flip_h == true: #changes the values used for jumping horizontally when the image gets flipped
		flipped = true
	else:
		flipped = false

##------------------------------------------------
##Used for ledge climbing
##-----------------------------------------------
func is_input_facing() -> bool:
	return (Input.get_axis("left","right")) == facing_direction

func is_ledge() -> bool:
	return is_on_wall() and ledge.is_colliding() and ledge.get_collision_normal().is_equal_approx(Vector2.UP)

func is_space() -> bool:
	space.global_position = ledge.get_collision_point()
	space.force_raycast_update()
	return not space.is_colliding()

func ledge_offset() -> Vector2:
	var shaped = collision_shape_2d.shape
	if shaped is RectangleShape2D:
		return Vector2(shaped.size.x, -shaped.size.y * 0.5)
	return Vector2.ZERO
##------------------------------------------------
##End of ledge climbing
##-----------------------------------------------

#forces players to jump on the opposite direction on wall jump
func set_facing_direction(direction: float) -> void:
	if direction:
		animated_sprite_2d.flip_h = direction < 0
		#Forces the raycast to change directions
		facing_direction = direction
		ledge.position.x = direction * absf(ledge.position.x)
		ledge.target_position.x = direction * absf(ledge.target_position.x)
		ledge.force_raycast_update()
		wall_slide.position.x = direction * absf(wall_slide.position.x)
		wall_slide.target_position.x = direction * absf(wall_slide.target_position.x)
		wall_slide.force_raycast_update()

func can_slide() -> bool: #used for wall sliding
	return is_on_wall_only() and wall_slide.is_colliding() and climb



func bounce() -> void: #used to define how superjumps work
	print("bfore.y ", velocity.y)
	print("bfore.x ", velocity.x)
	
	if velocity.y > 0 and velocity.x != 0 and velocity.y <= 250:
		velocity.y *= -3
	elif velocity.y < 0 and velocity.x != 0 and velocity.y >= -250:
		velocity.y *= 3
	if velocity.y > 0 and velocity.x != 0 and velocity.y <500 and velocity.y > 250:
		velocity.y *= -2
	elif velocity.y < 0 and velocity.x != 0 and velocity.y > -500 and velocity.y < -250:
		velocity.y *= 2
	elif velocity.x != 0 and velocity.y > 0 and velocity.y > 500:
		velocity.y *= -1.25
	elif velocity.x != 0 and velocity.y < 0 and velocity.y < -500:
		velocity.y *= 1.25
	print("velocity.y ", velocity.y)
	print("velocity.x ", velocity.x)
	


##------------------------------------------------
##Start of rope 
##-----------------------------------------------
func enter_rope(area):
	onRope = true
	reparent(area)
	global_position = area.get_rope_position(self)

func exit_rope():
	area_2d.monitoring = false
	onRope = false
	reparent(get_tree().current_scene)
	rotation_degrees = 0
	
	await get_tree().create_timer(1).timeout
	area_2d.monitoring = true
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("rope") and onRope == false:
		call_deferred("enter_rope", area)
	elif area.is_in_group("wall"):
		climb = false


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("rope") and onRope == true:
		onRope = false
	climb = true

##------------------------------------------------
##Start of bar
##-----------------------------------------------
func _setup_charge_bar() -> void:
	if not charge_bar:
		var bar = ProgressBar.new()
		bar.name = "ChargeBar"
		bar.unique_name_in_owner = true
		add_child(bar)
		charge_bar = bar
	charge_bar.visible = false
	charge_bar.show_percentage = false
	charge_bar.min_value = 0.0
	charge_bar.max_value = 100.0
	charge_bar.size = Vector2(30, 5)
	charge_bar.position = Vector2(-15, -18)
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.15, 0.85)
	bg_style.set_corner_radius_all(2)
	bg_style.set_border_width_all(1)
	bg_style.border_color = Color(0.35, 0.35, 0.45, 1.0)
	charge_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(1.0, 0.75, 0.1, 1.0)
	fill_style.set_corner_radius_all(2)
	charge_bar.add_theme_stylebox_override("fill", fill_style)
	
func _update_charge_bar(is_charging: bool) -> void:
	if not charge_bar:
		return
	if is_charging and abs(current_y) > 0:
		charge_bar.visible = true
		var ratio = clamp(abs(current_y) / abs(max_y), 0.0, 1.0)
		charge_bar.value = ratio * 100.0
		var fill_style: StyleBoxFlat = charge_bar.get_theme_stylebox("fill")
		if fill_style:
			if ratio >= 0.99:
				fill_style.bg_color = Color(0.349, 0.326, 0.904, 1.0) # Bright green at 100% full
			else:
				fill_style.bg_color = Color(0.515, 0.56, 0.98, 1.0) # Gold while charging
	else:
		charge_bar.visible = false
		charge_bar.value = 0.0

extends CharacterBody2D

@export var isPlayer2 = false

@export var SPEED = 160.0
@export var JUMP_VELOCITY = -250.0
@export var horizontal_jump_velocity = 80

@export_range(0, 1) var deceleration = 0.5
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var decelerate_on_jump_release = 0.2

@export var is_throwing = false
@export var MAX_CHARGE: float = 600
var CHARGE_INCREMENT: float = 600

var current_charge:float = 0

var claw: CharacterBody2D = null

var max_rotation = deg_to_rad(-36.0)  # Convert -36 degrees to radians
var min_rotation = 0.0  # Default rotation
var throw_rotation: float = deg_to_rad(36.0)  # +36 degrees for throw
var charge_ratio = 0.0

func _ready() -> void:
	claw = $Claw


func _process(delta: float) -> void:
	if isPlayer2 == false:
		if Input.is_action_pressed("p1_down"):
			is_throwing = true
			current_charge = move_toward(current_charge, MAX_CHARGE, delta * CHARGE_INCREMENT)
		else:
			current_charge = move_toward(current_charge, 0, delta * CHARGE_INCREMENT)

		# Clamp charge between 0 and MAX_CHARGE
		current_charge = clamp(current_charge, 0.0, MAX_CHARGE)

		# Claw rotation logic
		charge_ratio = current_charge / MAX_CHARGE  # Normalize charge from 0 to 1
		claw.rotation = clamp(lerp(min_rotation, max_rotation, charge_ratio), max_rotation, min_rotation)

	# Return to idle position after throw
	if is_throwing and claw.rotation != min_rotation:
		claw.rotation = move_toward(claw.rotation, min_rotation, delta * 5)  # Smooth return to 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isPlayer2 == false:
		# Handle jump.
		if Input.is_action_just_pressed("p1_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		if Input.is_action_just_released("p1_up") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("p1_left", "p1_right")
		if direction:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * (SPEED + horizontal_jump_velocity), SPEED * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)

	
	move_and_slide()

func throw():
	is_throwing = true
	

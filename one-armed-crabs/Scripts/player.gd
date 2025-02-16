extends CharacterBody2D

@export var isPlayer2 = false

@export var SPEED = 160.0
@export var JUMP_VELOCITY = -250.0
@export var horizontal_jump_velocity = 80

@export_range(0, 1) var deceleration = 0.5
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var decelerate_on_jump_release = 0.2

@export var charging = false
@export var MAX_CHARGE: float = 600
var CHARGE_INCREMENT: float = 500

var current_charge: float = 0
var is_throwing = false  # Flag to track if a throw is in progress
var is_returning = false  # Flag to track if the claw is returning
var canPick = true

var claw: CharacterBody2D = null
var charge_rotation = deg_to_rad(-36.0)  # -36 degrees (charging)
var default_rotation = 0.0  # Default rotation (idle position)
var throw_rotation = deg_to_rad(36.0)  # +36 degrees (throwing)
var charge_ratio = 0.0
var claw_return_speed = 0.01  # Speed at which the claw returns to 0 after throwing

var push_force = 80.0

func _ready() -> void:
	claw = $Claw

func _process(delta: float) -> void:
	if isPlayer2 == false:
		# Charging mechanic
		if Input.is_action_pressed("p1_down") and not is_throwing and not is_returning:
			current_charge = move_toward(current_charge, MAX_CHARGE, delta * CHARGE_INCREMENT)
			charge_ratio = current_charge / MAX_CHARGE
			claw.rotation = lerp(default_rotation, charge_rotation, charge_ratio)
		
		# Throwing action when button is released
		elif Input.is_action_just_released("p1_down") and not is_throwing and not is_returning:
			is_throwing = true
			claw.rotation = lerp(charge_rotation, throw_rotation, charge_ratio)
			
			# Short delay before returning to idle position
			await get_tree().create_timer(0.1).timeout
			
			# Start return animation
			is_returning = true
			while abs(claw.rotation - default_rotation) > 0.01:
				claw.rotation = move_toward(claw.rotation, default_rotation, claw_return_speed)
				await get_tree().process_frame

			# Reset charge and flags
			current_charge = 0
			is_throwing = false
			is_returning = false  # End of return animation, allow throwing again
		
		# Reset charge when not holding the charge button
		else:
			current_charge = move_toward(current_charge, 0, delta * CHARGE_INCREMENT)  # Optional: Reset charge when not holding

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isPlayer2 == false:
		# Handle jump.
		if Input.is_action_just_pressed("p1_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		if Input.is_action_just_released("p1_up") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release

		# Movement handling
		var direction := Input.get_axis("p1_left", "p1_right")
		if direction:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * (SPEED + horizontal_jump_velocity), SPEED * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)

	move_and_slide()
	
	# To push the ball, do not touch
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

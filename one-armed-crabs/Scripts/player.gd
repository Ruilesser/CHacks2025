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

var current_charge:float = 0
var is_throwing = false  # Flag to track if a throw is in progress

var claw: CharacterBody2D = null

var max_rotation = deg_to_rad(-36.0)  # -36 degrees (charging)
var min_rotation = 0.0  # Default rotation (idle position)
var throw_rotation = deg_to_rad(36.0)  # +36 degrees (throwing)
var charge_ratio = 0.0

var claw_return_speed = 0.05  # Speed at which the claw returns to 0 after throwing

func _ready() -> void:
	claw = $Claw

func _process(delta: float) -> void:
	if isPlayer2 == false:
		# Charging mechanic
		if Input.is_action_pressed("p1_down"):
			current_charge = move_toward(current_charge, MAX_CHARGE, delta * CHARGE_INCREMENT)
		else:
			current_charge = move_toward(current_charge, 0, delta * CHARGE_INCREMENT)  # Optional: Reset charge when not holding
		
		# Charge to -36 degrees (charging)
		charge_ratio = current_charge / MAX_CHARGE
		claw.rotation = lerp(min_rotation, max_rotation, charge_ratio)
		
		# If released, execute throw
		if Input.is_action_just_released("p1_down") and not is_throwing:
			is_throwing = true
		
			# Step 1: Reflect the current charge to a positive value
			var reflected_rotation = deg_to_rad(abs(current_charge / MAX_CHARGE) * 36)  # Convert to degrees based on charge ratio (reflect to positive)

			# Step 2: Instantly snap to reflected positive rotation
			claw.rotation = lerp(max_rotation, throw_rotation, charge_ratio)

			# Step 4: Smoothly return to 0 (idle position)
			while abs(claw.rotation - min_rotation) > 0.01:
				claw.rotation = move_toward(claw.rotation, min_rotation, claw_return_speed)
				await get_tree().process_frame

			# Reset charge and flag
			current_charge = 0
			is_throwing = false

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

func throw():
	# Start the throwing phase
	if not is_throwing:
		is_throwing = true
		
		# Step 1: Reflect the current charge to a positive value
		var reflected_rotation = deg_to_rad(abs(current_charge / MAX_CHARGE) * 36)  # Convert to degrees based on charge ratio (reflect to positive)

		# Step 2: Instantly snap to reflected positive rotation
		claw.rotation = reflected_rotation

		# Step 3: Hold for a short time before returning to 0
		await get_tree().create_timer(0.2).timeout  # Short delay before returning to 0

		# Step 4: Smoothly return to 0 (idle position)
		while abs(claw.rotation - min_rotation) > 0.01:
			claw.rotation = move_toward(claw.rotation, min_rotation, claw_return_speed)
			await get_tree().process_frame

		# Reset charge and flag
		current_charge = 0
		is_throwing = false

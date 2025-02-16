extends CharacterBody2D

@onready var claw_grab_box: Area2D = $Claw/ClawGrabBox
@onready var player_1: CharacterBody2D = $"."

@export var isPlayer2 = false

@export var SPEED = 160.0
@export var JUMP_VELOCITY = -250.0
@export var horizontal_jump_velocity = 80

@export_range(0, 1) var deceleration = 0.5
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var decelerate_on_jump_release = 0.2

@export var charging = false
@export var MAX_CHARGE: float = 360
var CHARGE_INCREMENT: float = 500

var current_charge: float = 0
var is_throwing = false  # Flag to track if a throw is in progress
var is_returning = false  # Flag to track if the claw is returning
var canPick = true

var closest_throwable_distance = INF
var closest_area2d_to_clawbox = null
var area2d_in_clawbox = []

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
		# Reset charge when not holding the charge button
		
		if Input.is_action_pressed("p1_grab") and not is_throwing and not is_returning and canPick:
			# print("omg guys you can grab stuff")
			closest_area2d_to_clawbox = null # assume no thing is found
			
			for i in area2d_in_clawbox:
				if i.position.distance_to(claw_grab_box.position) < closest_throwable_distance:
					closest_throwable_distance = i.position.distance_to(claw_grab_box.position)
					closest_area2d_to_clawbox = i
			
			if closest_area2d_to_clawbox and closest_area2d_to_clawbox.owner.get_name() == "Ball":
				canPick = false
				print("my name is: ")
				
				
		elif Input.is_action_just_released("p1_grab"):
			canPick = true
			closest_throwable_distance = INF
			
			
	#end of process()



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




func _on_claw_grab_box_area_entered(area: Area2D) -> void:
	print("area in claw range")
	area2d_in_clawbox.append(area) # add to items

func _on_claw_grab_box_area_exited(area: Area2D) -> void:
	area2d_in_clawbox.erase(area) #no longer in the area
	if area == closest_area2d_to_clawbox:
		closest_throwable_distance = INF


#func _on_claw_grab_box_body_entered(body: Node2D) -> void:
	#print("body in claw range")
	#print(body.get_name())
	#if body is Ball:
		#area2d_in_clawbox.append(body) # add to items
#
#func _on_claw_grab_box_body_exited(body: Node2D) -> void:
	#area2d_in_clawbox.erase(body) #no longer in the area
	#if body == closest_area2d_to_clawbox:
		#closest_throwable_distance = INF

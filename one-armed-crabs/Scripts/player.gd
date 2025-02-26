extends CharacterBody2D

@onready var claw_grab_box: Area2D = $Claw/ClawGrabBox
@onready var player_1: CharacterBody2D = $"."
@onready var animated_sprite = $AnimatedSprite2D
@onready var animated_claw = $Claw/AnimatedSprite2D
@onready var marker_2d: Marker2D = $Claw/Marker2D
@onready var aim_marker: Marker2D = $Claw/AimMarker
@onready var area_2d: Area2D = null

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
var grabbed_object = null
var area2d_in_clawbox = []
var body_in_clawbox = []
var closest_body_to_clawbox = null

var claw: CharacterBody2D = null
var charge_rotation = deg_to_rad(-36.0)  # -36 degrees (charging)
var default_rotation = 0.0  # Default rotation (idle position)
var throw_rotation = deg_to_rad(36.0)  # +36 degrees (throwing)
var charge_ratio = 0.0
var claw_return_speed = 0.03  # Speed at which the claw returns to 0 after throwing

var reflection_ratio = -1

var push_force = 80.0
var direction = 1

func _ready() -> void:
	claw = $Claw
	area_2d = $Area2D
	await get_tree().create_timer(0.1).timeout
	area_2d.set_monitoring(true)

func _process(delta: float) -> void:
	rotation_degrees = 0
	
	if(area_2d.is_monitoring() == false):
		$Area2D/CollisionShape2D2.set_disabled(true)
		global_position = get_parent().global_position
		return
	else:
		$Area2D/CollisionShape2D2.set_disabled(false)
	
	
	if isPlayer2 == false:
		# Charging mechanic
		
		if Input.is_action_just_pressed("p1_down"):
			play_sound($charge_sfx)
		if Input.is_action_just_released("p1_down"):
			play_sound($hit_sfx)
		
		if Input.is_action_pressed("p1_down") and not is_throwing and not is_returning:
			current_charge = move_toward(current_charge, MAX_CHARGE, delta * CHARGE_INCREMENT)
			charge_ratio = current_charge / MAX_CHARGE
			claw.rotation = lerp(default_rotation, charge_rotation, charge_ratio)
		
		# Throwing action when button is released
		elif Input.is_action_just_released("p1_down") and not is_throwing and not is_returning:
			is_throwing = true
				
			claw.rotation = lerp(charge_rotation, throw_rotation, charge_ratio)
			animated_claw.frame = 0
			
			# let go of grabbed item
			if grabbed_object:
				if grabbed_object is RigidBody2D:
					grabbed_object.reparent(player_1.get_parent())
					grabbed_object.set_freeze_enabled(false)
					var distance = aim_marker.global_position - marker_2d.global_position
					
					grabbed_object.set_linear_velocity(distance * current_charge/30 )
				elif grabbed_object is CharacterBody2D:
					grabbed_object.reparent(player_1.get_parent())
					closest_area2d_to_clawbox.set_monitoring(true)
					var distance = aim_marker.global_position - marker_2d.global_position
					
					grabbed_object.set_velocity(distance * current_charge/30 )
			grabbed_object = null
			
			# Short delay before returning to idle position
			await get_tree().create_timer(0.1).timeout
			
			# Start return animation
			is_returning = true
			while abs(claw.rotation - default_rotation) > 0.01:
				claw.rotation = move_toward(claw.rotation, default_rotation, claw_return_speed)
				await get_tree().process_frame

			# Reset charge and flags
			canPick = true
			current_charge = 0
			is_throwing = false
			is_returning = false  # End of return animation, allow throwing again
			
		
		# Reset charge when not holding the charge button
		else:
			current_charge = move_toward(current_charge, 0, delta * CHARGE_INCREMENT)  # Optional: Reset charge when not holding
		# Reset charge when not holding the charge button
		
		if Input.is_action_just_pressed("p1_grab"):
			play_sound($grab_sfx)
		
		if Input.is_action_pressed("p1_grab") and not is_throwing and not is_returning and canPick:
			# print("omg guys you can grab stuff")
			# play_sound($grab_sfx)
			closest_area2d_to_clawbox = null # assume no thing is found
			animated_claw.frame = 1
			
			for i in area2d_in_clawbox:
				if i.global_position.distance_to(claw_grab_box.global_position) < closest_throwable_distance:
					closest_throwable_distance = i.global_position.distance_to(claw_grab_box.global_position)
					closest_area2d_to_clawbox = i
			
			if closest_area2d_to_clawbox and closest_area2d_to_clawbox.owner is RigidBody2D: #Ball
				canPick = false
				# print("my name is: ")
				grabbed_object = closest_area2d_to_clawbox.owner
				grabbed_object.set_freeze_enabled(true)
				if grabbed_object.get_parent():
					grabbed_object.reparent(marker_2d)
				else:
					marker_2d.add_child(grabbed_object)
			elif  closest_area2d_to_clawbox and closest_area2d_to_clawbox.owner is CharacterBody2D: #player2
				canPick = false
				# print("my name is: ")
				grabbed_object = closest_area2d_to_clawbox.owner
				closest_area2d_to_clawbox.set_monitoring(false)
				if grabbed_object.get_parent():
					grabbed_object.reparent(marker_2d)
				else:
					marker_2d.add_child(grabbed_object)
				
		else:
			animated_claw.frame = 0
		#elif Input.is_action_just_released("p1_grab"):
			#canPick = true
			#closest_throwable_distance = INF
			#animated_claw.frame = 0
			
	#end of player1 body
	#start of player2 body
	else:
		# Charging mechanic
		if Input.is_action_just_pressed("p2_down"):
			play_sound($charge_sfx)
		if Input.is_action_just_released("p2_down"):
			play_sound($hit_sfx)
		
		if Input.is_action_pressed("p2_down") and not is_throwing and not is_returning:
			#play_sound($charge_sfx)
			current_charge = move_toward(current_charge, MAX_CHARGE, delta * CHARGE_INCREMENT)
			charge_ratio = current_charge / MAX_CHARGE
			claw.rotation = lerp(default_rotation, -1*charge_rotation, charge_ratio)
		
		# Throwing action when button is released
		elif Input.is_action_just_released("p2_down") and not is_throwing and not is_returning:
			#play_sound($hit_sfx)
			is_throwing = true
				
			claw.rotation = lerp(-1*charge_rotation, -1* throw_rotation, charge_ratio)
			animated_claw.frame = 0
			
			# let go of grabbed item
			if grabbed_object:
				if grabbed_object is RigidBody2D:
					grabbed_object.reparent(player_1.get_parent())
					grabbed_object.set_freeze_enabled(false)
					var distance = aim_marker.global_position - marker_2d.global_position
					
					grabbed_object.set_linear_velocity(distance * current_charge/(30) )
				elif grabbed_object is CharacterBody2D:
					grabbed_object.reparent(player_1.get_parent())
					closest_area2d_to_clawbox.set_monitoring(true)
					var distance = aim_marker.global_position - marker_2d.global_position
					
					grabbed_object.set_velocity(distance * current_charge/30 )
			grabbed_object = null
			
			# Short delay before returning to idle position
			await get_tree().create_timer(0.1).timeout
			
			# Start return animation
			is_returning = true
			while abs(claw.rotation - default_rotation) > 0.01:
				claw.rotation = move_toward(claw.rotation, default_rotation, claw_return_speed)
				await get_tree().process_frame

			# Reset charge and flags
			canPick = true
			current_charge = 0
			is_throwing = false
			is_returning = false  # End of return animation, allow throwing again
			
		
		# Reset charge when not holding the charge button
		else:
			current_charge = move_toward(current_charge, 0, delta * CHARGE_INCREMENT)  # Optional: Reset charge when not holding
		# Reset charge when not holding the charge button
		
		if Input.is_action_just_pressed("p2_grab"):
			play_sound($grab_sfx)
		
		if Input.is_action_pressed("p2_grab") and not is_throwing and not is_returning and canPick:
			# play_sound($grab_sfx)
			# print("omg guys you can grab stuff")
			closest_area2d_to_clawbox = null # assume no thing is found
			animated_claw.frame = 1
			
			for i in area2d_in_clawbox:
				if i.global_position.distance_to(claw_grab_box.global_position) < closest_throwable_distance:
					closest_throwable_distance = i.global_position.distance_to(claw_grab_box.global_position)
					closest_area2d_to_clawbox = i
			
			if closest_area2d_to_clawbox and closest_area2d_to_clawbox.owner is RigidBody2D: #Ball
				canPick = false
				# print("my name is: ")
				grabbed_object = closest_area2d_to_clawbox.owner
				grabbed_object.set_freeze_enabled(true)
				if grabbed_object.get_parent():
					grabbed_object.reparent(marker_2d)
				else:
					marker_2d.add_child(grabbed_object)
			elif  closest_area2d_to_clawbox and closest_area2d_to_clawbox.owner is CharacterBody2D: #player2
				canPick = false
				# print("my name is: ")
				grabbed_object = closest_area2d_to_clawbox.owner
				closest_area2d_to_clawbox.set_monitoring(false)
				if grabbed_object.get_parent():
					grabbed_object.reparent(marker_2d)
				else:
					marker_2d.add_child(grabbed_object)
				
		else:
			animated_claw.frame = 0
		#elif Input.is_action_just_released("p1_grab"):
			#canPick = true
			#closest_throwable_distance = INF
			#animated_claw.frame = 0
			
	#end of player2 body
	#end of process()



func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if isPlayer2 == false:
		# Handle jump.
		if Input.is_action_just_pressed("p1_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			play_sound($jump_sfx)
			
		if Input.is_action_just_released("p1_up") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release

		# Movement handling
		direction = Input.get_axis("p1_left", "p1_right")
		if direction:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * (SPEED + horizontal_jump_velocity), SPEED * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)
			
	#end of player 1 input
	else:
		# Handle jump.
		if Input.is_action_just_pressed("p2_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			play_sound($jump_sfx)
			
		if Input.is_action_just_released("p2_up") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release

		# Movement handling
		direction = Input.get_axis("p2_left", "p2_right")
		if direction:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * (SPEED + horizontal_jump_velocity), SPEED * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)

	move_and_slide()
	handle_movement_animation(direction)
	
	# To push the ball, do not touch
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)


func handle_movement_animation(dir):
	if !velocity:
		animated_sprite.play("idle")
	if velocity:
		animated_sprite.play("walking")
		toggle_flip_sprite(dir)

func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = true
	if dir == -1:
		animated_sprite.flip_h = false


func _on_claw_grab_box_area_entered(area: Area2D) -> void:
	print("area in claw range")
	area2d_in_clawbox.append(area) # add to items

func _on_claw_grab_box_area_exited(area: Area2D) -> void:
	area2d_in_clawbox.erase(area) #no longer in the area
	if area == closest_area2d_to_clawbox:
		closest_throwable_distance = INF

func _on_claw_grab_box_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D and body != claw:
		#print(body.get_name())
		#body_in_clawbox.append(body) # add to items
	pass

func _on_claw_grab_box_body_exited(body: Node2D) -> void:
	#if body is CharacterBody2D and body.owner != player_1 :
		#body_in_clawbox.erase(body) # add to items
		#if body == closest_body_to_clawbox:
			#closest_throwable_distance = INF
	pass

func play_sound(sfx: AudioStreamPlayer):
	randomize()
	sfx.pitch_scale = randf_range(0.8, 1.2)
	sfx.play()

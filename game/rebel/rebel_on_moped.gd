extends KinematicBody2D

var current_speed
var current_swerve
var velocity = Vector2()

var swerve_hold_time = 0
var swerve_release_time = 0
var is_swerve_pressed = false

func _ready():
	G.node_rebel_on_moped = self
	current_speed = G.moped_config_min_speed
	current_swerve = 0
	
func _adjust_swerve_speed_by_time(swerve_direction):
	#increase swerve speed for amoutn of time button held
	#if speed below maximum and button is held
	if (is_swerve_pressed and abs(current_swerve) <= G.moped_config_swerve_speed):
		current_swerve += (sign(swerve_direction)*(G.moped_config_acceleration_rate * swerve_hold_time))
		
	#if button isnt held and there is still swerving speed left
	#decrease to zero (with safety threshold to actually catch 0)
	if (not is_swerve_pressed and abs(current_swerve) > 0):
		current_swerve += (-sign(swerve_direction)*(G.moped_config_acceleration_rate * swerve_release_time))
		if (abs(current_swerve) <= G.moped_config_swerve_neutral_threshold):
			current_swerve = 0


	
	
func _physics_process(delta):
	
	if (is_swerve_pressed):
		swerve_hold_time += delta
	else:
		swerve_release_time += delta
	
	if (Input.is_action_just_pressed('swerve_up') or
	Input.is_action_just_pressed('swerve_down')):
		is_swerve_pressed = true
		swerve_hold_time = 0
	
	if Input.is_action_pressed('accelerate'):
		current_speed += 0
	if Input.is_action_pressed('brake'):
		current_speed -= 0
	if Input.is_action_pressed('swerve_up'):
		_adjust_swerve_speed_by_time(-1)
	if Input.is_action_pressed('swerve_down'):
		_adjust_swerve_speed_by_time(1)
		
	current_speed = clamp(
		current_speed, 
		G.moped_config_min_speed, 
		G.moped_config_max_speed
	)
	current_swerve = clamp(
		current_swerve,
		-G.moped_config_swerve_speed,
		G.moped_config_swerve_speed
	)
	
	velocity = Vector2(current_speed, current_swerve)
	
	move_and_slide(velocity)
	
func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true

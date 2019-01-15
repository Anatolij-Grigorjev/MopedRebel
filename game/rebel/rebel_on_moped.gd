extends KinematicBody2D

var current_speed
var current_swerve
var velocity = Vector2()

var swerve_hold_time = 0
var swerve_release_time = 0
var is_swerve_pressed = false

var accelleration_hold_time = 0
var acceleration_release_time = 0
var is_acceleration_pressed = false

var break_hold_time = 0
var is_brake_pressed = false

func _ready():
	G.node_rebel_on_moped = self
	current_speed = G.moped_config_min_speed
	current_swerve = 0
	
func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true
	
func _physics_process(delta):
	
	_handle_swerve_control(delta)
	_handle_forward_acceleration(delta)
	current_speed = clamp(
		current_speed, 
		G.moped_config_min_speed, 
		G.moped_config_max_speed
	)
	_handle_breaking(delta)
	
	if (current_swerve != 0 and current_speed > 0):
		#reduce forward pseed by coef based on swerve intensity
		_adjust_current_speed_to_swerve()
	
	velocity = Vector2(current_speed, current_swerve)
	
	move_and_slide(velocity)
	
	

func _handle_swerve_control(delta):
	if (is_swerve_pressed):
		swerve_hold_time += delta
	else:
		swerve_release_time += delta
	
	if (Input.is_action_just_pressed('swerve_up') or
	Input.is_action_just_pressed('swerve_down')):
		is_swerve_pressed = true
		swerve_hold_time = 0
	if (Input.is_action_just_released("swerve_up") or
	Input.is_action_just_released("swerve_down")):
		is_swerve_pressed = false
		swerve_release_time = 0
	
	if Input.is_action_pressed('swerve_up'):
		_increase_swerve_speed_by_time(-1)
	if Input.is_action_pressed('swerve_down'):
		_increase_swerve_speed_by_time(1)
		
	if (not is_swerve_pressed):
		_neutralize_swerve_speed()
	#apply threshold to not swerve on small press
	if (abs(current_swerve) <= G.moped_config_swerve_neutral_threshold):
		current_swerve = 0
	current_swerve = clamp(
		current_swerve,
		-G.moped_config_swerve_speed,
		G.moped_config_swerve_speed
	)

func _increase_swerve_speed_by_time(swerve_direction):
	#increase swerve speed for amoutn of time button held
	#if speed below maximum and button is held
	if (is_swerve_pressed and abs(current_swerve) <= G.moped_config_swerve_speed):
		current_swerve += (
			sign(swerve_direction) * 
			(G.moped_config_swerve_acceleration_rate * swerve_hold_time)
		)

func _neutralize_swerve_speed():
	#if button isnt held and there is still swerving speed left
	#decrease to zero 
	if (not is_swerve_pressed and abs(current_swerve) > 0):
		current_swerve += (
			-sign(current_swerve) * 
			(G.moped_config_swerve_acceleration_rate * swerve_release_time)
		)
		

func _handle_forward_acceleration(delta):
	if (is_acceleration_pressed):
		accelleration_hold_time += delta
	else:
		acceleration_release_time += delta
	
	if (Input.is_action_just_pressed('accelerate')):
		is_acceleration_pressed = true
		accelleration_hold_time = 0
	if (Input.is_action_just_released('accelerate')):
		is_acceleration_pressed = false
		acceleration_release_time = 0
		
	_increase_acceleration_by_time()
	
	
func _increase_acceleration_by_time():
	if (is_acceleration_pressed and current_speed < G.moped_config_max_speed):
		#if the player has not been holding acceleration for long they will 
		#accelerate more slowly, acceleration rate grows linearly up to max
		var acceleration_reduce_coef = (
			min(accelleration_hold_time, G.moped_config_max_acceleration_reach_time)
			/ G.moped_config_max_acceleration_reach_time
		)
		current_speed += (
			(G.moped_config_max_acceleration_rate * acceleration_reduce_coef)
			* accelleration_hold_time
		)

func _handle_breaking(delta):
	
	if (is_brake_pressed):
		break_hold_time += delta
		
	if (Input.is_action_just_pressed('brake')):
		is_brake_pressed = true
		break_hold_time = 0
	if (Input.is_action_just_released('brake')):
		is_brake_pressed = false
		
	_increase_brake_by_time(delta)
	

func _increase_brake_by_time(delta):
	if (is_brake_pressed and current_speed > G.moped_config_min_speed):
		current_speed -= (
			G.moped_config_brake_intensity * break_hold_time
		)


func _adjust_current_speed_to_swerve():
	
	var swerve_intensity_coef = abs(current_swerve) / G.moped_config_swerve_speed
	var max_fwd_to_swerve_speed_diff = current_speed - F.y2z(current_speed)
	#reduce current speed by how intensely a swerve is happening 
	#if swerving full speed forward movement will slow down 
	#a bit more to accomodate manuever
	current_speed -= (max_fwd_to_swerve_speed_diff * swerve_intensity_coef)


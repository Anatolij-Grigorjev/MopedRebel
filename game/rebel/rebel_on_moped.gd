extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)

const MOPED_SUDDEN_STOP_COEF = 3.75
var dissing_zone_node_scene = preload("res://rebel/dissing_zone.tscn")

var current_speed
var current_swerve = 0
var velocity = Vector2()

var swerve_hold_time = 0
var swerve_release_time = 0
var is_swerve_pressed = false

var accelleration_hold_time = 0
var acceleration_release_time = 0
var is_acceleration_pressed = false

var brake_hold_time = 0
var brake_release_time = 0
var is_brake_pressed = false

var is_unmounting_moped = false
var remaining_collision_recovery = 0

var facing_direction

var active_sprite

var diss_positions_control
var active_dissing_zone

func _ready():
	facing_direction = C.FACING.RIGHT
	G.node_rebel_on_moped = self
	active_sprite = $sprite_on_moped
	diss_positions_control = $diss_positions
	reset_velocity()
	
func reset_velocity():
	current_speed = G.moped_config_min_speed
	_reset_swerve()
	_reset_acceleration()
	_reset_braking()
	
func _reset_swerve():
	current_swerve = 0
	swerve_hold_time = 0
	swerve_release_time = 0
	is_swerve_pressed = false
	
func _reset_acceleration():
	accelleration_hold_time = 0
	acceleration_release_time = 0
	is_acceleration_pressed = false
	
func _reset_braking():
	brake_hold_time = 0
	is_brake_pressed = false

	
func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true
	
func _physics_process(delta):
	
	if (remaining_collision_recovery > 0):
		remaining_collision_recovery = max(
			remaining_collision_recovery - delta, 0)
		_perform_sudden_stop(delta)
		if (remaining_collision_recovery <= 0):
			reset_velocity()
	else:
		_process_no_collision(delta)
	
	
	velocity = Vector2(
		facing_direction * current_speed, 
		current_swerve
	)
	var collision = move_and_collide(velocity * delta)
	if (collision):
		#bump around by car
		if (collision.collider.is_in_group(C.GROUP_CARS)):
			velocity = velocity.bounce(collision.normal)
			remaining_collision_recovery = _get_moped_recovery_for_bounce(velocity)
			current_speed = velocity.x
			current_swerve = velocity.y
			
func _get_moped_recovery_for_bounce(bounce_velocity):
	var bounce_sq = bounce_velocity.length_squared()
	# max recovery time reserved only for travelling max speed.
	# proportionally, 
	#
	# max speed - max recovery
	# bounce speed - x recovery
	#
	# (max recovery * bounce speed) / max speed = x recovery
	return (
		(G.moped_config_crash_recovery_time * bounce_sq) 
		/ 
		G.moped_config_max_flat_velocity_sq
	)

func _perform_sudden_stop(delta):
	var reduce_speed_by = (delta * G.moped_config_brake_intensity * MOPED_SUDDEN_STOP_COEF)
	current_speed = current_speed + (-sign(current_speed) * reduce_speed_by)


func _process_no_collision(delta):
	if (is_unmounting_moped):
		if (current_speed > 0):
			_perform_sudden_stop(delta)
		else:
			current_speed = 0
			is_unmounting_moped = false
			S.emit_signal0(S.SIGNAL_REBEL_UNMOUNT_MOPED)
	else:
		_handle_unmounting_moped()
		_handle_facing_direction(delta)
		_handle_swerve_control(delta)
		_handle_forward_acceleration(delta)
		_handle_brakeing(delta)
		current_speed = clamp(
			current_speed, 
			G.moped_config_min_speed, 
			G.moped_config_max_speed
		)	
		if (current_swerve != 0 and current_speed > 0):
			#reduce forward pseed by coef based on swerve intensity
			_adjust_current_speed_to_swerve()
		_handle_diss_zone()


func _handle_unmounting_moped():
	if (not is_unmounting_moped):
		if (Input.is_action_pressed('unmount_moped')):
			is_unmounting_moped = true

func _handle_facing_direction(delta):
	
	var brake_action = _brake_action_for_facing()
	var double_tap_direction = (Input.is_action_pressed(brake_action) 
		and brake_release_time < C.DOUBLE_TAP_LIMIT)
	
	if (double_tap_direction 
		or Input.is_action_just_released('turn_around')
	):
		facing_direction = F.flip_facing(facing_direction)
		$sprite_on_moped.scale.x = abs($sprite_on_moped.scale.x) * facing_direction
		reset_velocity()

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
		
	var accelerate_action = _accelerate_action_for_facing()
	
	if (Input.is_action_just_pressed(accelerate_action)):
		is_acceleration_pressed = true
		accelleration_hold_time = 0
	if (Input.is_action_just_released(accelerate_action)):
		is_acceleration_pressed = false
		acceleration_release_time = 0
		
	_increase_acceleration_by_time()

func _accelerate_action_for_facing():
	return 'accelerate_right' if facing_direction == C.FACING.RIGHT else 'accelerate_left'
	
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

func _handle_brakeing(delta):
	
	if (is_brake_pressed):
		brake_hold_time += delta
	else:
		brake_release_time += delta
		
	var brake_action = _brake_action_for_facing()
		
	if (Input.is_action_just_pressed(brake_action)):
		is_brake_pressed = true
		brake_hold_time = 0
	if (Input.is_action_just_released(brake_action)):
		is_brake_pressed = false
		brake_release_time = 0
		
	_increase_brake_by_time(delta)
	
func _brake_action_for_facing():
	return 'brake_right' if facing_direction == C.FACING.RIGHT else 'brake_left'
	

func _increase_brake_by_time(delta):
	if (is_brake_pressed and current_speed > G.moped_config_min_speed):
		current_speed -= (
			G.moped_config_brake_intensity * brake_hold_time
		)


func _adjust_current_speed_to_swerve():
	
	var swerve_intensity_coef = abs(current_swerve) / G.moped_config_swerve_speed
	var max_fwd_to_swerve_speed_diff = current_speed - F.y2z(current_speed)
	#reduce current speed by how intensely a swerve is happening 
	#if swerving full speed forward movement will slow down 
	#a bit more to accomodate manuever
	current_speed -= (max_fwd_to_swerve_speed_diff * swerve_intensity_coef)
	
func _handle_diss_zone():
	if Input.is_action_pressed('flip_bird'):
		if (active_dissing_zone == null):
			active_dissing_zone = dissing_zone_node_scene.instance()
			add_child(active_dissing_zone)
		_set_dissing_zone_position()
	else:
		if (active_dissing_zone != null):
			active_dissing_zone.clear_present_nodes()
			active_dissing_zone.queue_free()
			active_dissing_zone = null
			
func _set_dissing_zone_position():
	var active_position_node = diss_positions_control.active_diss_position_node
	if (active_position_node != null):
		active_dissing_zone.global_position = active_position_node.global_position
		active_dissing_zone.rotation_degrees = diss_positions_control.active_diss_zone_angle
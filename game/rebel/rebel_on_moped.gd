extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)

var check_collision_layers = [
	C.LAYERS_CURB,
	C.LAYERS_TRANSPORT_ROAD
]

const MOPED_SUDDEN_STOP_COEF = 3.75
var dissing_zone_node_scene = preload("res://rebel/dissing_zone.tscn")

enum MOPED_GROUND_TYPES {
	ROAD = 0,
	SIDEWALK = 1
}

var moped_ground_type = MOPED_GROUND_TYPES.ROAD
var velocity = Vector2()

var current_speed = 0
var speed_alter_direction = 0
var current_swerve = 0
var swerve_direction = 0

var is_unmounting_moped = false
var remaining_collision_recovery = 0

var facing_direction

var active_sprite

var diss_positions_control
var active_dissing_zone

var moped_engine_tween

func _ready():
	facing_direction = C.FACING.RIGHT
	G.node_rebel_on_moped = self
	active_sprite = $sprite_on_moped
	diss_positions_control = $diss_positions
	moped_engine_tween = $moped_engine_tween
	G.track_action_press_release('accelerate_right')
	G.track_action_press_release('accelerate_left')
	reset_velocity()
	
func reset_velocity():
	current_speed = G.moped_config_min_speed
	_reset_swerve()
	_reset_acceleration()
	
func _reset_swerve():
	current_swerve = 0
	swerve_direction = 0
	
func _reset_acceleration():
	speed_alter_direction = 0

var last_enabled_collision_layer_state = []
	
func disable():
	last_enabled_collision_layer_state = F.get_node_collision_layer_state(self)
	F.set_node_collision_layer_bits(self, false)
	for mask_layer in check_collision_layers:
		set_collision_mask_bit(mask_layer, false)
	set_physics_process(false)
	visible = false
	
func enable():
	var enabled_bits = []
	for idx in range(0, last_enabled_collision_layer_state.size()):
		if (last_enabled_collision_layer_state[idx]):
			enabled_bits.append(idx)
	F.set_node_collision_layer_bits(self, true, enabled_bits)
	for mask_layer in check_collision_layers:
		set_collision_mask_bit(mask_layer, true)
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
		_process_not_collided(delta)
	
	var velocity_speed = (
		facing_direction * 
		(
			F.y2z(current_speed) if (_is_moped_swerving()) 
			else current_speed
		)
	)
	velocity = Vector2(
		velocity_speed, 
		current_swerve
	)
	var collision = move_and_collide(velocity * delta)
	if (collision):
		LOG.debug("new collision: %s", [collision])
		#bump around by car
		if (collision.collider.is_in_group(C.GROUP_CARS)):
			_bounce_from_colliding_heavy(collision)
		#do conflict if the collider can manage it
		if (_collider_has_conflict_collision_node(collision)):
			_collision_receiver_react_collision(collision)

func _is_moped_swerving():
	return current_swerve != 0 and current_speed > 0


func _bounce_from_colliding_heavy(collision):
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
	
func _collider_has_conflict_collision_node(collision):
	return collision.collider.has_node('conflict_collision_receiver')
	
func _collision_receiver_react_collision(collision):
	collision.collider.conflict_collision_receiver.react_collision(collision)

func _perform_sudden_stop(delta):
	var reduce_speed_by = (delta * G.moped_config_brake_intensity * MOPED_SUDDEN_STOP_COEF)
	current_speed = current_speed + (-sign(current_speed) * reduce_speed_by)


func _process_not_collided(delta):
	if (is_unmounting_moped):
		if (current_speed > 0):
			_perform_sudden_stop(delta)
		else:
			current_speed = 0
			is_unmounting_moped = false
			S.emit_signal0(S.SIGNAL_REBEL_UNMOUNT_MOPED)
	else:
		_handle_unmounting_moped()
		_handle_jumping_curb()
		_handle_facing_direction()
		_handle_swerve_control()
		_handle_forward_acceleration()
		current_speed = clamp(
			current_speed, 
			G.moped_config_min_speed, 
			G.moped_config_max_speed
		)
		_handle_diss_zone()


func _handle_unmounting_moped():
	if (not is_unmounting_moped):
		if (Input.is_action_pressed('unmount_moped')):
			is_unmounting_moped = true
			
func _handle_jumping_curb():
	if (Input.is_action_just_released('jump_curb')):
		S.emit_signal0(S.SIGNAL_REBEL_JUMP_CURB_ON_MOPED)
		moped_ground_type = (moped_ground_type + 1) % 2
		_set_moped_ground_layers()
		
func _set_moped_ground_layers():
	var moped_on_road = moped_ground_type == MOPED_GROUND_TYPES.ROAD
	set_collision_layer_bit(C.LAYERS_REBEL_ROAD, moped_on_road)
	set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, not moped_on_road)

func _handle_facing_direction():
	
	var facing_speed_actions = _get_speed_actions_for_facing()
	var brake_action = facing_speed_actions[1]
	var double_tap_direction = (Input.is_action_pressed(brake_action) 
		and G.PRESSED_ACTIONS_TRACKER[brake_action].last_released_time < C.DOUBLE_TAP_LIMIT)
	
	if (double_tap_direction 
		or Input.is_action_just_released('turn_around')
	):
		facing_direction = F.flip_facing(facing_direction)
		$sprite_on_moped.scale.x = abs($sprite_on_moped.scale.x) * facing_direction
		reset_velocity()

func _handle_swerve_control():

	var new_swerve_direction = 0
	
	if Input.is_action_pressed('swerve_up'):
		new_swerve_direction = -1
	if Input.is_action_pressed('swerve_down'):
		new_swerve_direction = 1
		
	if (new_swerve_direction != swerve_direction):
		var swerve_target_speed = G.moped_config_swerve_speed * new_swerve_direction
		var complete_swerve_time = abs((swerve_target_speed - current_swerve) / G.moped_config_swerve_acceleration_rate)
		if (swerve_target_speed == 0):
			#breaking is FACTOR times faster than accelerating
			complete_swerve_time /= MOPED_SUDDEN_STOP_COEF
		#ensure swerve tween from current
		_start_new_swerve_tween(swerve_target_speed, complete_swerve_time)
		swerve_direction = new_swerve_direction
		
func _start_new_swerve_tween(final_swerve_speed, swerve_duration):
	moped_engine_tween.remove(self, 'current_swerve')
	if (current_swerve != final_swerve_speed):
		LOG.info("Starting to swerve from %s to %s in %s sec!", 
			[
				current_swerve, 
				final_swerve_speed, 
				swerve_duration
			])
		moped_engine_tween.interpolate_property(
			self, 
			'current_swerve',
			 current_swerve,
			final_swerve_speed,
			swerve_duration,
			Tween.TRANS_EXPO,
			Tween.EASE_OUT_IN
		)
		moped_engine_tween.start()

func _handle_forward_acceleration():
		
	var new_speed_alter_direction = _get_new_speed_alter_direction()
	#change acceleration tween state
	if (new_speed_alter_direction != speed_alter_direction):
		if (new_speed_alter_direction > 0):
			var acceleration_time = (G.moped_config_max_speed - current_speed) / G.moped_config_max_acceleration_rate
			_start_new_acceleration_tween(G.moped_config_max_speed, acceleration_time)
		elif (new_speed_alter_direction < 0):
			var slowdown_time = (current_speed - G.moped_config_min_speed) / G.moped_config_brake_intensity
			_start_new_acceleration_tween(G.moped_config_min_speed, slowdown_time)
		else:
			#dont tween if neither direction is insisted
			moped_engine_tween.stop(self, 'current_speed')
		speed_alter_direction = new_speed_alter_direction

func _get_new_speed_alter_direction():
	var change_speed_actions = _get_speed_actions_for_facing()
	var accelerate_action = change_speed_actions[0]
	var slowdown_action = change_speed_actions[1]
	
	#speed alter direction 0 is neutral
	var new_speed_alter_direction = 0
	if (Input.is_action_pressed(accelerate_action)):
		#speed alter direction 1 is accelerate
		new_speed_alter_direction = 1
	if (Input.is_action_pressed(slowdown_action)):
		#speed alter direction -1 is slowdown
		new_speed_alter_direction = -1
		
	return new_speed_alter_direction

func _get_speed_actions_for_facing():
	if (facing_direction == C.FACING.RIGHT):
		return ['accelerate_right', 'accelerate_left']
	else:
		return ['accelerate_left', 'accelerate_right']
	
func _start_new_acceleration_tween(final_speed, speed_shift_duration):
	moped_engine_tween.remove(self, 'current_speed')
	if (final_speed != current_speed):
		LOG.info("Starting to change speed from %s to %s in %s sec!", 
			[
				facing_direction * current_speed, 
				facing_direction * final_speed, 
				speed_shift_duration
			])
		moped_engine_tween.interpolate_property(
			self, 
			'current_speed',
			 current_speed,
			final_speed,
			speed_shift_duration,
			Tween.TRANS_EXPO,
			Tween.EASE_OUT_IN
		)
		moped_engine_tween.start()
	
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
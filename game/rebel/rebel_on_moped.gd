extends "rebel_base.gd"

var check_collision_layers = [
	C.LAYERS_CURB,
	C.LAYERS_TRANSPORT_ROAD
]
var last_enabled_collision_layer_state = []

const MOPED_SUDDEN_STOP_COEF = 3.75

enum MOPED_GROUND_TYPES {
	ROAD = 0,
	SIDEWALK = 1
}

var moped_ground_type = MOPED_GROUND_TYPES.ROAD

var current_speed = 0
var speed_alter_direction = 0
var current_swerve = 0
var swerve_direction = 0

var is_unmounting_moped = false
var remaining_collision_recovery = 0

var moped_engine_tween
var anim

func _ready():
	LOG = Logger.new('REBEL_MOPED')
	G.node_rebel_on_moped = self
	._ready()
	moped_engine_tween = $moped_engine_tween
	anim = $anim
	last_enabled_collision_layer_state = F.get_node_collision_layer_state(self)
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
		
func _disable_collision_layers():
	last_enabled_collision_layer_state = F.get_node_collision_layer_state(self)
	F.set_node_collision_layer_bits(self, false)
	for mask_layer in check_collision_layers:
		set_collision_mask_bit(mask_layer, false)

func _enable_collision_layers():
	var enabled_bits = []
	for idx in range(0, last_enabled_collision_layer_state.size()):
		if (last_enabled_collision_layer_state[idx]):
			enabled_bits.append(idx)
	F.set_node_collision_layer_bits(self, true, enabled_bits)
	for mask_layer in check_collision_layers:
		set_collision_mask_bit(mask_layer, true)
	
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
		LOG.info("new collision: %s", [collision])
		var collider = collision.collider
		if (collider is TileMap):
			if (is_unmounting_moped and collider.is_in_group(C.GROUP_CURB)):
				var animation_name = 'unmount_moped'
				var animation_length = anim.get_animation(animation_name).length
				play_nointerrupt_anim(animation_name)
				#remove swerve in half anim length
				_start_new_swerve_tween(0, animation_length)
				pass
			pass
		else:	
			#bump around by heavy collision (car)
			if (collider.is_in_group(C.GROUP_CARS)):
				_bounce_from_colliding_heavy(collision)
				if (collider.has_node('conflict_collision_receiver')):
					_use_collider_collision_receiver(collision)
				
				

func _is_moped_swerving():
	return current_swerve != 0 and current_speed > 0
	
func _use_collider_collision_receiver(collision):
	var collider = collision.collider
	var collision_receiver = collider.conflict_collision_receiver
	collision_receiver.react_collision(collision)
	
func _finish_unmounting():
	rotation = 0
	is_unmounting_moped = false
	reset_velocity()
	S.emit_signal0(S.SIGNAL_REBEL_UNMOUNT_MOPED)

func _bounce_from_colliding_heavy(collision):
	velocity = velocity.bounce(collision.normal)
	remaining_collision_recovery = _get_moped_recovery_for_bounce(velocity)
	current_speed = velocity.x
	current_swerve = velocity.y
	play_nointerrupt_anim("crash_transport")


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


func _process_not_collided(delta):
	if (is_unmounting_moped):
		pass
	else:
		if (not control_locked):
			_handle_unmounting_moped()
			_handle_jumping_curb()
			_handle_facing_direction()
			_handle_swerve_control()
			_handle_forward_acceleration()
			_process_dissing_zone()
		current_speed = clamp(
			current_speed, 
			G.moped_config_min_speed, 
			G.moped_config_max_speed
		)

#dynamic animation from road to lead moped up to curb and then 
#1.dismount
#2.jump curb
#curb from below is px up to first curb tile +(64+30)px/scale for center + collider start

func _handle_unmounting_moped():
	if (not is_unmounting_moped):
		if (Input.is_action_pressed('unmount_moped')):
			is_unmounting_moped = true
			var anim_name = 'moped_swerve_up'
			var animation_length = anim.get_animation(anim_name).length
			#play animation
			anim.play(anim_name)
			#dont go forward
			_start_new_acceleration_tween(0.0, animation_length)
			#go up halfspeed
			_start_new_swerve_tween(-G.moped_config_swerve_speed / 2, animation_length)
			
			
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
	
	var relevant_anim = "flip_moped"
	
	if (
		(double_tap_direction 
		or Input.is_action_just_released('turn_around'))
		and _not_playing_anim(relevant_anim)
	):
		reset_velocity()
		play_nointerrupt_anim(relevant_anim)
		
func _not_playing_anim(animation_name):
	return (not anim.is_playing() 
			or anim.current_animation != animation_name)
	
func _turn_around_moped():
	LOG.info(
		"PRE facing: %s, scale: %s, sprite scale: %s", 
		[facing_direction, scale.x, active_sprite.scale.x])
	facing_direction = F.flip_facing(facing_direction)
	#flip sprite to match facing
	scale.x *= -1
	active_sprite.scale.x = abs(active_sprite.scale.x)
	#turn around animation flips sprite scale so have to unflip it
	#to maintain same direction as transform
	LOG.info(
		"POST facing: %s, scale: %s, sprite scale: %s", 
		[facing_direction, scale.x, active_sprite.scale.x])
	reset_velocity()

func _handle_swerve_control():

	var new_swerve_direction = 0
	var anim_to_play = null
	if Input.is_action_pressed('swerve_up'):
		new_swerve_direction = -1
		anim_to_play = "moped_swerve_up"
	if Input.is_action_pressed('swerve_down'):
		new_swerve_direction = 1
		anim_to_play = "moped_swerve_down"
		
	if (new_swerve_direction != swerve_direction):
		var swerve_target_speed = G.moped_config_swerve_speed * new_swerve_direction
		var complete_swerve_time = abs((swerve_target_speed - current_swerve) / G.moped_config_swerve_acceleration_rate)
		if (swerve_target_speed == 0):
			#breaking is FACTOR times faster than accelerating
			complete_swerve_time /= MOPED_SUDDEN_STOP_COEF
			#unplay the current swerve animation
			var prev_swerve_anim = null
			if (swerve_direction == 1):
				prev_swerve_anim = "moped_swerve_down"
			else:
				prev_swerve_anim = "moped_swerve_up"
			anim.play_backwards(prev_swerve_anim)
		#ensure swerve tween from current
		_start_new_swerve_tween(swerve_target_speed, complete_swerve_time)
		swerve_direction = new_swerve_direction
		if (swerve_direction != 0):
			#play new swerve animation
			anim.play(anim_to_play)

		
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
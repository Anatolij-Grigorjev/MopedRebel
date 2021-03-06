extends "rebel_base.gd"

var check_collision_layers = [
	C.LAYERS_CURB,
	C.LAYERS_TRANSPORT_ROAD
]
var last_enabled_collision_layer_state = []

const MOPED_SUDDEN_STOP_COEF = 3.75
const CURB_GRIND_TIME_SEC = 1.0

var moped_ground_type

var current_speed = 0
var speed_alter_direction = 0
var current_swerve = 0
var swerve_direction = 0

var is_unmounting_moped = false
var is_jumping_curb = false
var is_grinding_curb = false

var remaining_collision_recovery = 0
var remain_curb_grind_time_sec = 0

var moped_engine_tween
var anim

func _ready():
	LOG = Logger.new('REBEL_MOPED')
	G.node_rebel_on_moped = self
	moped_ground_type = C.MOPED_GROUND_TYPES.ROAD
	moped_engine_tween = $moped_engine_tween
	anim = $anim
	last_enabled_collision_layer_state = F.get_node_collision_layer_state(self)
	G.track_action_press_release('accelerate_right')
	G.track_action_press_release('accelerate_left')
	reset_velocity()
	
func _finish_mount_moped(moped_ground_type):
	F.set_active_rebel_state(C.REBEL_STATES.ON_MOPED)
	global_position.x = G.node_rebel_on_foot.global_position.x
	match(moped_ground_type):
		C.MOPED_GROUND_TYPES.ROAD:
			pass
		C.MOPED_GROUND_TYPES.SIDEWALK:
			global_position.y = G.node_rebel_on_foot.global_position.y
			pass
		_: LOG.error("unsupported type of surface for moped %s", [moped_ground_type])
	self.moped_ground_type = moped_ground_type
	_set_moped_ground_layers()
	
func reduce_velocity(factor):
	current_speed = clamp(current_speed * factor, G.moped_config_min_speed, G.moped_config_max_speed)
	_reduce_swerve(factor)
	_reduce_acceleration(factor)
	_sprite_to_neutral()
	
func reset_velocity():
	reduce_velocity(0.0)
	
func _reduce_swerve(factor):
	current_swerve *= factor
	swerve_direction *= factor
	
func _reduce_acceleration(factor):
	speed_alter_direction *= factor
	
func _reset_swerve():
	_reduce_swerve(0.0)
	
func _reset_acceleration():
	_reduce_acceleration(0.0)
	
func _sprite_to_neutral():
	$sprite.scale = Vector2(0.45, 0.45)
	$sprite.rotation = 0
		
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
			remaining_collision_recovery - delta, 
			0
		)
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
			if (collider.is_in_group(C.GROUP_CURB)):
				var animation_name = null
				var swerve_length_coef = 1.0
				if (is_unmounting_moped):
					animation_name = 'unmount_moped'
				elif (is_jumping_curb):
					animation_name = 'moped_jump_curb'
					swerve_length_coef = 2.0
					var new_ground_type = (
						C.MOPED_GROUND_TYPES.SIDEWALK if moped_ground_type == C.MOPED_GROUND_TYPES.ROAD 
						else C.MOPED_GROUND_TYPES.ROAD
					)
					emit_signal("started_jumping_curb", new_ground_type)
				elif (not is_grinding_curb):
					is_grinding_curb = _rebel_swerve_towards_position(collision.position)
					if (is_grinding_curb):
						remain_curb_grind_time_sec = CURB_GRIND_TIME_SEC
						anim.play(anim.assigned_animation + '_grinding')
				if (animation_name):
					var animation_length = anim.get_animation(animation_name).length
					play_nointerrupt_anim(animation_name)
					_start_new_swerve_tween(0, animation_length * swerve_length_coef)
					yield($anim, "animation_finished")
					match(animation_name):
						"unmount_moped": _finish_unmounting()
						"moped_jump_curb": _finish_jumping()
						_: pass
			elif (collider.is_in_group(C.GROUP_BENCHES)):
				if (abs(collision.normal.x) > 0.4):
					LOG.info("collision bench: %s", [collision.normal])
					_bounce_from_colliding_heavy(collision, C.GROUP_BENCHES)
				pass
		else:	
			#bump around by heavy collision (car)
			if (_collider_is_heavy(collider)):
				_bounce_from_colliding_heavy(collision, C.GROUP_CARS)

			if (collider.has_node('conflict_collision_receiver')):
				_use_collider_collision_receiver(collision)

	elif (is_grinding_curb):
		_reset_grinding_curb()


func _is_moped_swerving():
	return current_swerve != 0 and current_speed > 0
	
func _rebel_swerve_towards_position(position):
	return (
		(position.y > low_position.global_position.y and current_swerve > 0)
		or 
		(position.y < low_position.global_position.y and current_swerve < 0)
	)
	
func _use_collider_collision_receiver(collision):
	var collider = collision.collider
	var collision_receiver = collider.conflict_collision_receiver
	collision_receiver.react_collision(collision)
	
func _reset_grinding_curb():
	is_grinding_curb = false
	remain_curb_grind_time_sec = 0
	var current_anim = anim.assigned_animation
	if (current_anim.ends_with('_grinding')):
		var no_grind_animation = F.substring(current_anim, 0, current_anim.length() - '_grinding'.length())
		var anim_object = anim.get_animation(no_grind_animation)
		anim.play(no_grind_animation)
		anim.seek(anim_object.length)
	
func _finish_unmounting():
	rotation = 0
	is_unmounting_moped = false
	reset_velocity()
	#unmounting moped places foot rebel right above curb on same location
	var sidewalk_position = global_position - Vector2(0, 50)
	#when moped is mounted back, we give the position some clearance
	global_position += Vector2(0, 50)
	emit_signal("finish_unmount_moped", sidewalk_position)
	
func _finish_jumping():
	_reset_grinding_curb()
	is_jumping_curb = false
	reduce_velocity(0.75)
	moped_ground_type = (
		C.MOPED_GROUND_TYPES.SIDEWALK if moped_ground_type == C.MOPED_GROUND_TYPES.ROAD 
		else C.MOPED_GROUND_TYPES.ROAD
	)
	_set_moped_ground_layers()
	
	
func _collider_is_heavy(collider):
	return (
		collider.is_in_group(C.GROUP_CARS)
		or collider.is_in_group(C.GROUP_OBSTACLES)
	)


func _bounce_from_colliding_heavy(collision, collider_group):
	velocity = velocity.bounce(collision.normal) * Vector2(sign(velocity.x), sign(velocity.y))
	current_speed = velocity.x
	current_swerve = velocity.y
	swerve_direction = sign(current_swerve)
	var crash_anim = null
	if (collider_group == C.GROUP_CARS):
		crash_anim = "crash_transport"
	else:
		crash_anim = "crash_obstacle"
	remaining_collision_recovery = $anim.get_animation(crash_anim).length
	LOG.info("normal: %s | velocity: %s | recovery: %s | collider: %s", [collision.normal, velocity, remaining_collision_recovery, collider_group])
	play_nointerrupt_anim(crash_anim)
	_start_new_acceleration_tween(G.moped_config_min_speed, remaining_collision_recovery)
	_start_new_swerve_tween(0, remaining_collision_recovery)


func _perform_sudden_stop(delta):
	var reduce_speed_by = (delta * G.moped_config_brake_intensity * MOPED_SUDDEN_STOP_COEF)
	current_speed = current_speed + (-sign(current_speed) * reduce_speed_by)


func _process_not_collided(delta):
	if (is_unmounting_moped):
		pass
	else:
		if (not control_locked):
			_handle_unmounting_moped()
			_handle_facing_direction()
			_handle_swerve_control()
			_handle_forward_acceleration()
			_process_grinding_curb(delta)
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
			var is_on_road = moped_ground_type == C.MOPED_GROUND_TYPES.ROAD
			var anim_name = ''
			if (is_on_road): 
				anim_name = 'moped_swerve_up'
				var animation_length = anim.get_animation(anim_name).length
				#play animation
				anim.play(anim_name)
				#dont go forward
				_start_new_acceleration_tween(0.0, animation_length)
				#go up halfspeed
				_start_new_swerve_tween(-G.moped_config_swerve_speed / 2, animation_length)
			else:
				anim_name = 'unmount_moped'
				
				play_nointerrupt_anim(anim_name)
				is_unmounting_moped = false

		
func _set_moped_ground_layers():
	var moped_on_road = moped_ground_type == C.MOPED_GROUND_TYPES.ROAD
	set_collision_layer_bit(C.LAYERS_REBEL_ROAD, moped_on_road)
	set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, not moped_on_road)

func _handle_facing_direction():
	var facing_speed_actions = _get_speed_actions_for_facing()
	var brake_action = facing_speed_actions[1]
	var double_tap_direction = (Input.is_action_pressed(brake_action) 
		and G.PRESSED_ACTIONS_TRACKER[brake_action].last_released_time < C.DOUBLE_TAP_LIMIT)
	
	var flip_moped_anim_name = "flip_moped"
	
	if (
		(double_tap_direction 
		or Input.is_action_just_released('turn_around'))
		and _not_playing_anim(flip_moped_anim_name)
	):
		play_nointerrupt_anim(flip_moped_anim_name)
		yield($anim, "animation_finished")
		_turn_around_moped()
		
func _not_playing_anim(animation_name):
	return (not anim.is_playing() 
			or anim.current_animation != animation_name)
	
func _turn_around_moped():
	LOG.info(
		"PRE facing: %s, scale: %s, sprite scale: %s", 
		[facing_direction, scale.x, active_sprite.scale.x])
	facing_direction = F.flip_facing(facing_direction)
	#flip char to match facing
	scale.x *= -1
	#turn around animation flips sprite scale so have to unflip it
	#to maintain same direction as transform
	active_sprite.scale.x = abs(active_sprite.scale.x)
	LOG.info(
		"POST facing: %s, scale: %s, sprite scale: %s", 
		[facing_direction, scale.x, active_sprite.scale.x])
	emit_signal("changed_facing", facing_direction)	
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
			Tween.EASE_OUT
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
		
func _process_grinding_curb(delta):
	if (is_grinding_curb):
		remain_curb_grind_time_sec -= delta
		if (remain_curb_grind_time_sec <= 0.0):
			is_jumping_curb = true
			_reset_grinding_curb()
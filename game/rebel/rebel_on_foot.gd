extends "rebel_base.gd"

var is_in_conflict = false

func _ready():
	LOG = Logger.new('REBEL_FOOT')
	G.node_rebel_on_foot = self
	connect('started_conflict_with', VS, 'rebel_started_conflict_with')
	
func _finish_unmount_moped(sidewalk_position):
	F.set_active_rebel_state(C.REBEL_STATES.ON_FOOT)
	global_position = sidewalk_position
		
func _disable_collision_layers():
	set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, false)

func _enable_collision_layers():
	set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, true)
	
func _physics_process(delta):
	if (not control_locked):
		velocity = Vector2()
		if Input.is_action_pressed('walk_right'):
			velocity.x += 1
		if Input.is_action_pressed('walk_left'):
			velocity.x -= 1
		if Input.is_action_pressed('walk_down'):
			velocity.y += 1
		if Input.is_action_pressed('walk_up'):
			velocity.y -= 1
		if (velocity.x != 0 and facing_direction != velocity.x):
			facing_direction = velocity.x
			emit_signal("changed_facing", facing_direction)
		velocity = velocity.normalized() * G.foot_config_walk_speed

		#in conflict, allow attack animations
		if (is_in_conflict):
			if Input.is_action_pressed('attack_1'):
				play_nointerrupt_anim('attack_1')
			pass
		else:	
		#outside of conflict allow mounting moped
			if Input.is_action_just_released('mount_moped'):
				#TODO: needs to be anim with taking moped through street
				play_nointerrupt_anim('mount_moped')
				
				yield($anim, "animation_finished")
				emit_signal("finish_mount_moped", C.MOPED_GROUND_TYPES.ROAD)
			if Input.is_action_just_released('mount_in_place'):
				#TODO: mount moped in place
				play_nointerrupt_anim('mount_moped')
				
				yield($anim, "animation_finished")
				emit_signal("finish_mount_moped", C.MOPED_GROUND_TYPES.SIDEWALK)
				
	
	var collision = move_and_collide(velocity * delta)
	if (collision):

		var collider = collision.collider
		#bump around by heavy collision (car)
		if (collider.is_in_group(C.GROUP_CITIZENS)):
			LOG.info("new citizen collision: %s", [collision])
			if (collider.has_node('conflict_collision_receiver')):
				_use_collider_collision_receiver(collision)
			if (not is_in_conflict):
				start_conflict(collision.collider)

func _use_collider_collision_receiver(collision):
	var collider = collision.collider
	var collision_receiver = collider.conflict_collision_receiver
	collision_receiver.react_collision(collision)
	
func start_conflict(enemy_node):
	is_in_conflict = true
	emit_signal("started_conflict_with", enemy_node)
	
func end_conflict():
	is_in_conflict = false
	
func escaped_conflict(escape_penalty):
	var penalty_tally_text = TallyText.instance()
	penalty_tally_text.text_type = C.INFO_TYPE.NEGATIVE
	penalty_tally_text.air_time = 2.0
	penalty_tally_text.text = "-%s sec." % escape_penalty
	#TODO: sprite extents insteado f hardcoded distance
	penalty_tally_text.rect_global_position = global_position + Vector2(50, -50)
	G.node_current_stage_root.add_child(penalty_tally_text)
	emit_signal("escaped_conflict")
	pass


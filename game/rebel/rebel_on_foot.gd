extends "rebel_base.gd"

func _ready():
	LOG = Logger.new('REBEL_FOOT')
	G.node_rebel_on_foot = self
	._ready()
		
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
		if (velocity.x != 0):
			facing_direction = velocity.x
		velocity = velocity.normalized() * G.foot_config_walk_speed
		
		if Input.is_action_just_released('mount_moped'):
			S.emit_signal0(S.SIGNAL_REBEL_MOUNT_MOPED)
			
		_process_dissing_zone()
	
	var collision = move_and_collide(velocity * delta)
	if (collision):
		LOG.info("new collision: %s", [collision])
		var collider = collision.collider
		#bump around by heavy collision (car)
		if (collider.is_in_group(C.GROUP_CITIZENS)):
			if (collider.has_node('conflict_collision_receiver')):
				_use_collider_collision_receiver(collision)

func _use_collider_collision_receiver(collision):
	var collider = collision.collider
	var collision_receiver = collider.conflict_collision_receiver
	collision_receiver.react_collision(collision)


extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)

var velocity = Vector2()
var dissing_zone_node_scene = preload("res://rebel/dissing_zone.tscn")
var active_dissing_zone

var diss_positions_control

var active_sprite

var enabled = true
var control_locked = false

func _ready():
	G.node_rebel_on_foot = self
	active_sprite = $sprite_on_foot
	diss_positions_control = $diss_positions

func disable():
	if (enabled):
		set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, false)
		set_physics_process(false)
		visible = false
		enabled = false
		$camera.clear_current()
	
func enable():
	if (not enabled):
		set_collision_layer_bit(C.LAYERS_REBEL_SIDEWALK, true)
		set_physics_process(true)
		visible = true
		enabled = true
		$camera.make_current()
		LOG.info("current rebel enabled FOOT")
	
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
		velocity = velocity.normalized() * G.foot_config_walk_speed
		
		if Input.is_action_just_released('mount_moped'):
			S.emit_signal0(S.SIGNAL_REBEL_MOUNT_MOPED)
			
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
	
	move_and_collide(velocity * delta)
	
func _set_dissing_zone_position():
	var active_position_node = diss_positions_control.active_diss_position_node
	if (active_position_node != null):
		active_dissing_zone.global_position = active_position_node.global_position
		active_dissing_zone.rotation_degrees = diss_positions_control.active_diss_zone_angle


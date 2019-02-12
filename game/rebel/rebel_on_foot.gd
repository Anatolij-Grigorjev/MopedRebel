extends KinematicBody2D

var velocity = Vector2()
var dissing_zone_node_scene = preload("res://rebel/dissing_zone.tscn")
var active_dissing_zone

var diss_right_pos_node
var diss_left_pos_node

func _ready():
	G.node_rebel_on_foot = self
	diss_right_pos_node = $diss_right_position
	diss_left_pos_node = $diss_left_position
	pass

func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true
	
func _physics_process(delta):
	
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
		_set_dissing_zone_position(sign(velocity.x))
	else:
		if (active_dissing_zone != null):
			active_dissing_zone.queue_free()
			active_dissing_zone = null
	
	var collision = move_and_collide(velocity * delta)
	
func _set_dissing_zone_position(facing):
	if (facing == C.FACING.RIGHT):
		active_dissing_zone.global_position = diss_right_pos_node.global_position
	if (facing == C.FACING.LEFT):
		active_dissing_zone.global_position = diss_left_pos_node.global_position

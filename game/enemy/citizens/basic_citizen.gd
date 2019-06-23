extends KinematicBody2D

var Logger = preload("res://globals/logger.gd")
var LOG

export(float) var max_visible_diss_distance = 450
export(float) var base_rebel_diss_gain = 0

var sprite
var should_move = false
var velocity = Vector2()
var walk_speed = 25
var run_speed = 40
var destination_proximity_variance = 10 

var diss_receiver
var conflict_collision_receiver
var moped_detect_area

var standing_position
var move_destination = null
var stage_chunk_idx

func _ready():
	add_to_group(C.GROUP_CITIZENS)
	sprite = $sprite
	moped_detect_area = $moped_detect_area
	diss_receiver = $diss_receiver
	conflict_collision_receiver = $conflict_collision_receiver
	standing_position = global_position
	LOG = Logger.new(self)
	pass

func _process(delta):
	if (should_move):
		move_and_collide(velocity * delta)
		if (move_destination != null):
			var destination_distance = global_position.distance_to(move_destination)
			if (destination_distance < destination_proximity_variance):
				should_move = false
				move_destination = null

	
func _finish_conflict():
	LOG.info("finish conflict")
	should_move = false
	diss_receiver.finish_being_dissed()
	$anim.play("post_conflict")
	set_physics_process(false)

func _start_diss_response():
	$check_rebel_direction_timer.start()
	_prepare_aggressive_response()
	velocity = F.get_speed_to_active_rebel_direction(self, walk_speed)

func _prepare_aggressive_response():
	should_move = true
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, true)
	
func _stop_diss_response():
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()
	should_move = true
	move_destination = standing_position
	velocity = (move_destination - global_position).normalized() * walk_speed
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, false)
	conflict_collision_receiver.reset_collision()
	
func _align_new_rebel_direction(new_direction):
	velocity = new_direction * walk_speed
	
func is_rebel_too_far():
	if F.is_rebel_state(C.REBEL_STATES.ON_MOPED):
		return true
	var distance_to_rebel = G.node_active_rebel.global_position.distance_to(
	global_position)
	return distance_to_rebel >= max_visible_diss_distance
	

func _on_body_entered_moped_detect_area(body):
	if (_body_is_moped_on_sidewalk(body)):
		_run_from_rebel(body)

func _on_body_exited_moped_detect_area(body):
	if (_body_is_moped_on_sidewalk(body)):
		should_move = false
	
func _body_is_moped_on_sidewalk(body):
	return (
		body == G.node_rebel_on_moped and 
		body.moped_ground_type == body.MOPED_GROUND_TYPES.SIDEWALK
	)

func _run_from_rebel(rebel_node):
	_prepare_aggressive_response()
	velocity = -1 * F.get_speed_to_active_rebel_direction(self, run_speed)
	
func get_current_rebel_diss_gain():
	var coef = conflict_collision_receiver.min_diss_sc / G.rebel_total_street_cred
	if (coef >= 0.5):
		return base_rebel_diss_gain * coef
	else:
		return 0
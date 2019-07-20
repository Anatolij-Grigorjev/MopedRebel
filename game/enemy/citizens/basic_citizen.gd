extends KinematicBody2D

var Logger = preload("res://globals/logger.gd")
var LOG

export(float) var max_visible_diss_distance = 450
export(float) var base_rebel_diss_gain = 0

var sprite
var should_move = false
var is_scared = false
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

	
func _finish_conflict_leave():
	should_move = false
	diss_receiver.finish_being_dissed()
	$anim.play("post_conflict")
	set_physics_process(false)

func _start_diss_response():
	$check_rebel_direction_timer.start()
	_prepare_aggressive_response()
	velocity = F.get_speed_to_active_rebel_direction(self, walk_speed)
	S.emit_signal1(S.SIGNAL_ENEMY_DISSED, self)

func _prepare_aggressive_response():
	should_move = true
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, true)
	
func _stop_diss_response():
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()
	should_move = true
	is_scared = false
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
	
func _receive_diss(diss_buildup):
	if (F.is_rebel_cooler_than(self)):
		diss_receiver.finish_being_dissed()
		_scared_by_rebel()
	
func _scared_by_rebel():
	if (not is_scared):
		is_scared = true
		S.emit_signal1(S.SIGNAL_ENEMY_SCARED, self)
		_run_from_rebel(G.node_active_rebel)
		$scared_run_timer.start()
	else:
		#reset the scare timer if got spooked again
		$scared_run_timer.stop()
		$scared_run_timer.start()
	pass

func _run_from_rebel(rebel_node):
	_prepare_aggressive_response()
	velocity = -1 * F.get_speed_to_active_rebel_direction(self, run_speed)
	
func get_current_rebel_diss_gain():
	return $type_props.diss_sc_gain

func _on_collision_with_rebel(collision_obj):
	if (F.is_rebel_cooler_than(self)):
		_finish_conflict_leave()
	else:
		should_move = false
		$anim.play('pre_conflict')
		
func move_to_conflict_position():
	var conflict_start_position = global_position - Vector2(150, 25)
	var move_time = $anim.current_animation_length - $anim.current_animation_position
	$position_shift.interpolate_property(
		self, 'global_position', #property location
		global_position, conflict_start_position, #from-to values
		move_time, Tween.TRANS_EXPO, Tween.EASE_OUT #transition props: duration/algo
	)
	$position_shift.start()
extends KinematicBody2D

export(float) var max_visible_diss_distance = 50
var sprite
var should_move = false
var velocity = Vector2()
var walk_speed = 25
var diss_receiver


func _ready():
	add_to_group(C.GROUP_CITIZENS)
	sprite = $sprite
	diss_receiver = $diss_receiver
	diss_receiver.diss_success_action_name = '_start_diss_response'
	diss_receiver.diss_reduction_predicate_name = 'is_rebel_too_far'
	$check_rebel_direction_timer.node_origin = self
	$check_rebel_direction_timer.node_receiver_action = '_align_new_rebel_direction'
	$conflict_collision_receiver.set_pre_conflict_collision_action(
		self,
		 "_stop_diss_response"
	)
	$conflict_collision_receiver.set_conflict_params(
		145,
		98,
		"22-34BB"
	)
	pass

func _process(delta):
	if (should_move):
		var collision = move_and_collide(velocity * delta)
		if (collision):
			$conflict_collision_receiver.react_collision(collision)
	pass

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
	velocity = Vector2(0, 0)
	should_move = false
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, false)
	$conflict_collision_receiver.reset_collision()
	
func _align_new_rebel_direction(new_direction):
	velocity = new_direction * walk_speed
	
func is_rebel_too_far():
	if (G.node_active_rebel == G.node_rebel_on_moped):
		return true
	return (
		G.node_active_rebel.global_position.distance_to(
			global_position) >= max_visible_diss_distance
	)
	
extends KinematicBody2D

var sprite
var should_move = false
var velocity = Vector2()
var walk_speed = 25
var diss_receiver


func _ready():
	add_to_group(C.GROUP_CITIZENS)
	sprite = $sprite
	diss_receiver = $diss_receiver
	diss_receiver.set_got_dissed_action('_start_diss_response')
	$check_rebel_direction_timer.connect('timeout', self, '_move_in_rebel_direction')
	pass

func _process(delta):
	if (should_move):
		var collision = move_and_collide(velocity * delta)
		if (collision):
			_stop_diss_response()
			S.emit_signal4(
				S.SIGNAL_REBEL_START_CONFLICT,
				self,
				145,
				98,
				"22-34BB"
			)
	pass

func _start_diss_response():
	$check_rebel_direction_timer.start()
	_prepare_aggressive_response()
	_move_in_rebel_direction()
	
func _move_in_rebel_direction():
	var rebel_direction = _get_rebel_direction()
	velocity = walk_speed * rebel_direction
	
func _get_rebel_direction():
	var rebel_position = G.node_active_rebel.global_position
	return (rebel_position - global_position).normalized()

func _prepare_aggressive_response():
	should_move = true
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, true)
	
func _stop_diss_response():
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()
	velocity = Vector2(0, 0)
	should_move = false
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, false)
	
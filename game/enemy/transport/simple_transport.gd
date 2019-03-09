extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)


export(float) var maintains_speed = 100
export(float) var max_visible_diss_distance = 90
export(Vector2) var maintains_direction = Vector2(1, 0)
 
var start_position = Vector2(0, 0)
var velocity = Vector2()
var should_stop = false

var stop_intensity = 0.0
var sprite
var diss_receiver
var target_direction
var target_speed

var conflict_collision_receiver

func _ready():
	start_position = global_position
	sprite = $sprite
	diss_receiver = $diss_receiver
	diss_receiver.diss_began_action_name = 'enter_diss_zone'
	diss_receiver.diss_stopped_action_name = 'exit_diss_zone'
	diss_receiver.diss_success_action_name = 'chase_while_dissed'
	diss_receiver.diss_reduction_predicate_name = 'is_rebel_too_far'
	$check_rebel_direction_timer.node_origin = self
	$check_rebel_direction_timer.node_receiver_action = '_align_new_rebel_direction'
	conflict_collision_receiver = $conflict_collision_receiver
	conflict_collision_receiver.set_conflict_params(
		150,
		100,
		'WHIMP'
	)
	conflict_collision_receiver.set_pre_conflict_collision_action(
		self, 
		"_pre_collide"
	)
	add_to_group(C.GROUP_CARS)
	reset_transport()
	
func _pre_collide():
	should_stop = true
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()

func _physics_process(delta):
	if (should_stop):
		target_speed = lerp(target_speed, 0, delta)
	else:
		target_speed = lerp(target_speed, maintains_speed, delta)
		
	velocity = target_direction * target_speed
	
	var collision = move_and_collide(delta * velocity)
	if (collision):
		conflict_collision_receiver.react_collision(collision)

func reset_transport():
	global_position = start_position
	should_stop = false
	_set_target_direction(maintains_direction)
	_set_target_speed(maintains_speed)
	conflict_collision_receiver.reset_collision()
	diss_receiver.finish_being_dissed()
	
func _set_target_direction(direction):
	target_direction = direction
	sprite.scale.x = abs(sprite.scale.x) * sign(direction.x)
	
func _set_target_speed(speed):
	target_speed = speed
	
func enter_diss_zone():
	if (not conflict_collision_receiver.collided):
		should_stop = true

func exit_diss_zone():
	if (not conflict_collision_receiver.collided):
		should_stop = false
	
func chase_while_dissed():
	if (not conflict_collision_receiver.collided):
		should_stop = false
		$check_rebel_direction_timer.start()

func _screen_exited():
	$post_leave_wait.stop()
	$post_leave_wait.start()

func _screen_entered():
	#reset timer when car onscreen
	#not to dissapear it
	if (not $post_leave_wait.is_stopped()):
		$post_leave_wait.stop()
	
func _offscreen_grace_timeout():
	reset_transport()
	
func is_rebel_too_far():
	if (G.node_active_rebel == G.node_rebel_on_foot):
		return true
	return (
		G.node_active_rebel.global_position.distance_to(
			global_position) >= max_visible_diss_distance
	)
	
	
func _align_new_rebel_direction(new_direction):
	if (not $conflict_collision_receiver.collided):
		_set_target_direction(new_direction)

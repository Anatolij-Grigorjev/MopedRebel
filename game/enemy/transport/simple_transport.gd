extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)

var CarCrashed = preload("res://enemy/transport/car_blue/car_blue1_crashed.tscn")

export(float) var maintains_speed = 100
export(float) var max_visible_diss_distance = 600
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
	diss_receiver.diss_calmdown_action_name = '_pre_collide'
	diss_receiver.diss_reduction_predicate_name = 'is_rebel_too_far'
	$check_rebel_direction_timer.node_origin = self
	$check_rebel_direction_timer.node_receiver_action = '_align_new_rebel_direction'
	conflict_collision_receiver = $conflict_collision_receiver
	conflict_collision_receiver.set_conflict_params(
		150,
		50,
		'WHIMP'
	)
	conflict_collision_receiver.set_pre_conflict_collision_action(
		self, 
		"_pre_collide"
	)
	_config_acceleration_tween(0.0)
	_config_deacceleration_tween(maintains_speed)
	add_to_group(C.GROUP_CARS)
	reset_transport()
	
func _config_acceleration_tween(starting_speed):
	$accelerate_tween.remove(self, 'velocity:x')
	$accelerate_tween.interpolate_property(self, 'velocity:x', starting_speed, maintains_speed, 1.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	
func _config_deacceleration_tween(starting_speed):
	$deaccelerate_tween.remove(self, 'velocity:x')
	$deaccelerate_tween.interpolate_property(self, 'velocity:x', starting_speed, 0.0, 1.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	
func _pre_collide():
	should_stop = conflict_collision_receiver.collided
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()
	if (not should_stop):
		_set_target_direction(maintains_direction)
	else:
		diss_receiver.shutdown_receiver()

func _physics_process(delta):
	if (should_stop):
		if (velocity.x > 0 and not $deaccelerate_tween.is_active()):
			_config_deacceleration_tween(velocity.x)
			$deaccelerate_tween.start()
	else:
		if (velocity.x < maintains_speed and not $accelerate_tween.is_active()):
			_config_acceleration_tween(velocity.x)
			$accelerate_tween.start()
	
	var collision = move_and_collide(delta * velocity * target_direction)
	if (collision):
		conflict_collision_receiver.react_collision(collision)

func reset_transport():
	global_position = start_position
	should_stop = false
	_set_target_direction(maintains_direction)
	conflict_collision_receiver.reset_collision()
	diss_receiver.startup_receiver()
	diss_receiver.finish_being_dissed()
	$accelerate_tween.start()
	
func _set_target_direction(direction):
	target_direction = direction
	sprite.scale.x = abs(sprite.scale.x) * sign(direction.x)
	
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
	
func is_rebel_too_far():
	if F.is_rebel_state(C.REBEL_STATES.ON_FOOT):
		return true
	return (
		G.node_active_rebel.global_position.distance_to(
			global_position) >= max_visible_diss_distance
	)
	
func _align_new_rebel_direction(new_direction):
	if (not $conflict_collision_receiver.collided):
		_set_target_direction(new_direction)
	
	
func _post_conflict():
	var crashed_stub = CarCrashed.instance()
	crashed_stub.crash_position = global_position
	LOG.info("setting crashed car to be at %s", [crashed_stub.crash_position])
	var stub_sprite = crashed_stub.get_node('sprite')
	stub_sprite.scale.x = abs(stub_sprite.scale.x) * sign(target_direction.x)
	get_parent().add_child(crashed_stub)
	
	queue_free()

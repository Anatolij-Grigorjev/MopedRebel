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
var velocity_tween

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
	velocity_tween = $velocity_tween
	add_to_group(C.GROUP_CARS)
	reset_transport()
	
func _pre_collide():
	should_stop = conflict_collision_receiver.collided
	diss_receiver.finish_being_dissed()
	$check_rebel_direction_timer.stop()
	if (not should_stop):
		_set_target_direction(maintains_direction)
	else:
		diss_receiver.shutdown_receiver()
		velocity_tween.stop_all()
		$anim.play("crash")
		set_physics_process(false)

func _physics_process(delta):
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
	_start_velocity_tween(maintains_speed, 1.5)

func _start_velocity_tween(to_velocity, tween_time):
	velocity_tween.remove(self, 'velocity:x')
	velocity_tween.interpolate_property(self, 'velocity:x', 
		velocity.x, to_velocity, 
		tween_time, 
		Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	velocity_tween.start()
	
func _set_target_direction(direction):
	target_direction = direction
	scale.x = abs(scale.x) * sign(direction.x)
	
func enter_diss_zone():
	if (not conflict_collision_receiver.collided):
		should_stop = true
		_start_velocity_tween(0, 1.5)

func exit_diss_zone():
	if (not conflict_collision_receiver.collided):
		should_stop = false
		_start_velocity_tween(maintains_speed, 1.5)
	
func chase_while_dissed():
	if (not conflict_collision_receiver.collided):
		should_stop = false
		_start_velocity_tween(maintains_speed, 1.5)
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


func _on_body_entered_obstacle_zone(body):
	LOG.info("body in obstacle zone: %s", [body])
	if (F.is_body_active_rebel(body) and body.facing_direction != maintains_direction.x):
		#slow down a bit
		_start_velocity_tween(maintains_speed / 2, 1.0)
		#TODO: honk horn at rebel

func _on_body_exited_obstacle_zone(body):
	if (not F.is_rebel_in_area($obstacle_warning_zone)):
		#speed back up
		_start_velocity_tween(maintains_speed, 1.0)

func _on_body_entered_crash_zone(body):
	LOG.info("body in carsh zone: %s", [body])
	if (F.is_body_active_rebel(body) and body.facing_direction != maintains_direction.x):
		_start_velocity_tween(0.0, 0.5)
		#TODO: keep hoking till they leave

func _on_body_exited_crash_zone(body):
	#TODO: stop honking incessantly
	var new_speed = maintains_speed / 2
	if (not F.is_rebel_in_area($obstacle_warning_zone)):
		new_speed *= 2
	#speed back up
	_start_velocity_tween(new_speed, 1.5)

extends KinematicBody2D

var LOG = preload("res://globals/logger.gd").new(self)

export(float) var maintains_speed = 100
export(float) var max_visible_diss_distance = 600
export(Vector2) var maintains_direction = Vector2(1, 0)
export(float) var base_rebel_diss_gain = 0
 
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
	conflict_collision_receiver = $conflict_collision_receiver
	velocity_tween = $velocity_tween
	reset_transport()
		

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
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	velocity_tween.start()
	
func _set_target_direction(direction):
	target_direction = direction
	scale.x = abs(scale.x) * sign(direction.x)
	#flip collision receiver scale relative to parent for
	#text readability
	if (sign(scale.x) < 0):
		$conflict_collision_receiver.scale.x *= -1
	
func enter_diss_zone(diss_level):
	if (not conflict_collision_receiver.collided):
		should_stop = true
		_start_velocity_tween(0, 1.5)

func exit_diss_zone(diss_level):
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
	
func get_current_rebel_diss_gain():
	return $type_props.diss_sc_gain

func _on_collision_with_rebel(collision_obj):
	if (F.is_rebel_cooler_than(self)):
		diss_receiver.shutdown_receiver()
		velocity_tween.stop_all()
		set_physics_process(false)
		$anim.play("crash")
		yield($anim, "animation_finished")
		queue_free()
	else:
		var animation_name = "crash_light"
		var anim_length = $anim.get_animation(animation_name).length
		_start_velocity_tween(0.0, anim_length)
		$anim.play(animation_name)


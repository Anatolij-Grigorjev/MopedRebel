extends KinematicBody2D


export(float) var maintains_speed = 100
export(Vector2) var maintains_direction = Vector2(1, 0)
export(float) var bribe_money = 100
export(float) var required_sc = 150
export(String) var driver_toughness = 'WHIMP'
 
var start_position = Vector2(0, 0)
var velocity = Vector2()
var should_stop = false
var collided = false

var stop_intensity = 0.0
var sprite
var diss_receiver
var target_direction

func _ready():
	start_position = global_position
	sprite = $sprite
	diss_receiver = $diss_receiver
	diss_receiver.set_diss_began_action('enter_diss_zone')
	diss_receiver.set_diss_stopped_action('exit_diss_zone')
	diss_receiver.set_got_dissed_action('chase_while_dissed')
	add_to_group(C.GROUP_CARS)
	reset_transport()

func _physics_process(delta):
	if (should_stop):
		velocity.x = lerp(velocity.x, 0, stop_intensity)
		if (velocity.x > stop_intensity):
			#keep stopping and colliding
			move_and_slide(velocity)
	else:
		
		var target_velocity = target_direction * maintains_speed
		#speedup back if speed reduced by stopping previously
		if (velocity.length_squared() < target_velocity.length_squared()):
			velocity.x = lerp(velocity.x, target_velocity.x, delta)
			velocity.y = lerp(velocity.y, target_velocity.y, delta)

		move_and_collide(delta * velocity)

func reset_transport():
	global_position = start_position
	velocity = abs(maintains_speed) * maintains_direction
	should_stop = false
	collided = false
	_set_target_direction(maintains_direction)
	diss_receiver.finish_being_dissed()
	
func _set_target_direction(direction):
	target_direction = direction
	sprite.scale.x = abs(sprite.scale.x) * sign(direction.x)
	
func react_collision(collision):
	should_stop = true
	collided = true
	diss_receiver.finish_being_dissed()
	stop_intensity = get_physics_process_delta_time()
	
func enter_diss_zone():
	should_stop = true
	stop_intensity = get_physics_process_delta_time()

func exit_diss_zone():
	should_stop = false
	
func chase_while_dissed():
	should_stop = false
	_set_target_direction(F.get_speed_to_active_rebel_direction(self))
	

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

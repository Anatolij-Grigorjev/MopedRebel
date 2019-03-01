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
var target_speed

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
		target_speed = lerp(target_speed, 0, delta)
	else:
		target_speed = lerp(target_speed, maintains_speed, delta)
		
	velocity = target_direction * target_speed
	
	var collision = move_and_collide(delta * velocity)
	if (collision):
		react_collision(collision)

func reset_transport():
	global_position = start_position
	should_stop = false
	collided = false
	_set_target_direction(maintains_direction)
	_set_target_speed(maintains_speed)
	diss_receiver.finish_being_dissed()
	
func _set_target_direction(direction):
	target_direction = direction
	sprite.scale.x = abs(sprite.scale.x) * sign(direction.x)
	
func _set_target_speed(speed):
	target_speed = speed
	
func react_collision(collision):
	if (not collided):
		F.logf("new collision: %s", [collision])
		should_stop = true
		collided = true
		diss_receiver.finish_being_dissed()
		S.emit_signal(S.SIGNAL_REBEL_START_CONFLICT,
			self,
			bribe_money,
			required_sc,
			driver_toughness
		)
	
	
func enter_diss_zone():
	if (not collided):
		should_stop = true

func exit_diss_zone():
	if (not collided):
		should_stop = false
	
func chase_while_dissed():
	if (not collided):
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

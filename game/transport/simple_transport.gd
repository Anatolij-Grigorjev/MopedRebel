extends KinematicBody2D

export(float) var maintains_speed = 100
export(float) var bribe_money = 100
export(float) var required_sc = 150
export(String) var driver_toughness = 'WHIMP'
 
var start_position = Vector2(0, 0)
var velocity = Vector2()
var collided = false

func _ready():
	start_position = global_position
	add_to_group(C.GROUP_CARS)
	reset_position()
	velocity = Vector2(maintains_speed, 0)

func _physics_process(delta):
	if (collided):
		velocity = lerp(velocity, 0, delta * 5)
		if (velocity > 0):
			move_and_slide(velocity)
		else:
			_initiate_conflict_signal()
	else:
		var collision = move_and_collide(delta * velocity)
		if (collision):
			velocity = velocity.bounce(collision.normal)
			collided = true

func reset_position():
	global_position = start_position
	
func _initiate_conflict_signal():
	S.emit_signal1(S.SIGNAL_TRANSPORT_START_CONFLICT, self)

func _screen_exited():
	$post_leave_wait.stop()
	$post_leave_wait.start()

func _screen_entered():
	#reset timer when car onscreen
	#not to dissapear it
	if (not $post_leave_wait.is_stopped()):
		$post_leave_wait.stop()
	
func _offscreen_grace_timeout():
	reset_position()

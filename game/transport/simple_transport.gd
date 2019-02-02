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
	reset_transport()

func _physics_process(delta):
	if (collided):
		velocity.x = lerp(velocity.x, 0, delta*2)
		if (velocity.x > 0):
			move_and_slide(velocity)
		else:
			pass
	else:
		move_and_collide(delta * velocity)

func reset_transport():
	global_position = start_position
	velocity = Vector2(maintains_speed, 0)
	collided = false
	$sprite.flip_h = sign(maintains_speed) >= 0
	
func react_collision(collision):
	collided = true


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

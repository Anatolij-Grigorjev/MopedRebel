extends KinematicBody2D


export(float) var maintains_speed = 100
export(float) var bribe_money = 100
export(float) var required_sc = 150
export(String) var driver_toughness = 'WHIMP'
 
var start_position = Vector2(0, 0)
var velocity = Vector2()
var should_stop = false
var collided = false
var is_dissed = false
var stop_itensity = 0.0
var maintains_direction = C.FACING.RIGHT
var sprite

func _ready():
	start_position = global_position
	sprite = $sprite
	add_to_group(C.GROUP_CARS)
	reset_transport()

func _physics_process(delta):
	if (should_stop):
		velocity.x = lerp(velocity.x, 0, stop_itensity)
		if (velocity.x > 0):
			#keep stopping and colliding
			move_and_slide(velocity)
		else:
			#if dissed try chase the player after stopping
			if (is_dissed):
				should_stop = false
	else:
		var target_speed_magnitude = abs(maintains_speed)
		#speedup back if speed reduced by stopping previously
		if (abs(velocity.x) < target_speed_magnitude):
			velocity.x = lerp(velocity.x, sign(velocity.x) * target_speed_magnitude, delta * 2)
		if (is_dissed):
			#try move towards active rebel on road
			if (G.node_active_rebel == G.node_rebel_on_moped):
				var current_rebel_position = G.node_rebel_on_moped.global_position
				var direction_to_rebel = current_rebel_position - global_position
				var target_velocity = direction_to_rebel * target_speed_magnitude
				velocity.x = lerp(velocity.x, target_velocity.x, delta * 2)
				velocity.y = lerp(velocity.y, target_velocity.y, delta * 2)
				F.logf("direction to rebel: %s | velocity: %s", [direction_to_rebel, velocity])
			else:
				is_dissed = false
		move_and_collide(delta * velocity)

func reset_transport():
	global_position = start_position
	maintains_direction = F.get_facing_for_velocity(maintains_speed)
	velocity = Vector2(abs(maintains_speed) * maintains_direction, 0)
	should_stop = false
	collided = false
	is_dissed = false
	sprite.scale.x = abs(sprite.scale.x) * maintains_direction
	
func react_collision(collision):
	should_stop = true
	collided = true
	stop_itensity = get_physics_process_delta_time() * 2
	
func enter_diss_zone():
	should_stop = true
	is_dissed = true
	stop_itensity = get_physics_process_delta_time() * 3

func exit_diss_zone():
	is_dissed = false
	should_stop = false

func has_collided_with(other_node):
	return collided

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

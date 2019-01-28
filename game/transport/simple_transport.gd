extends KinematicBody2D

export(float) var maintains_speed = 100
export(float) var bribe_money = 100
export(float) var required_sc = 150
export(String) var driver_toughness = 'WHIMP'
 
var start_position = Vector2(0, 0)
var velocity = Vector2()

func _ready():
	start_position = global_position
	add_to_group(C.GROUP_CARS)
	reset_position()
	velocity = Vector2(maintains_speed, 0)

func _physics_process(delta):
 	var collision = move_and_collide(delta * velocity)

func reset_position():
	global_position = start_position

func _screen_exited():
	reset_position()
	

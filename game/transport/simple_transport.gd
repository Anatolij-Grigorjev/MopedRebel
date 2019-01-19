extends KinematicBody2D

export(float) var maintains_speed = 100
var start_position = Vector2(0, 0)

func _ready():
	start_position = global_position
	reset_position()

func _physics_process(delta):
	global_position.x += delta * maintains_speed

func reset_position():
	global_position = start_position

func _screen_exited():
	reset_position()
	

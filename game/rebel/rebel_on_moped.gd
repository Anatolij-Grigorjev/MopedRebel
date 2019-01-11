extends KinematicBody2D

var current_velocity

func _ready():
	current_velocity = Vector2(C.MIN_MOPED_SPEED, 0)
	
	
func _physics_process(delta):
	
	if Input.is_action_pressed('accelerate'):
		current_velocity.x += C.MOPED_ACCELERATION_RATE
	if Input.is_action_pressed('brake'):
		current_velocity.x -= C.MOPED_ACCELERATION_RATE
	if Input.is_action_pressed('swerve_up'):
		current_velocity.y += C.MOPED_Z_SPEED
	if Input.is_action_pressed('swerve_down'):
		current_velocity.y -= C.MOPED_Z_SPEED
	
	move_and_slide(current_velocity)
	
func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true

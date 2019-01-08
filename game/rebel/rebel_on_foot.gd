extends KinematicBody2D

var walk_speed = 200
var velocity = Vector2()

func _ready():
	pass
	
func _physics_process(delta):
	
	velocity = Vector2()
	if Input.is_action_pressed('walk_right'):
		velocity.x += 1
	if Input.is_action_pressed('walk_left'):
		velocity.x -= 1
	if Input.is_action_pressed('walk_down'):
		velocity.y += 1
	if Input.is_action_pressed('walk_up'):
		velocity.y -= 1
	velocity = velocity.normalized() * walk_speed
	
	move_and_slide(velocity)

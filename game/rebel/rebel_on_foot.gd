extends KinematicBody2D

var velocity = Vector2()

func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true

func _ready():
	G.node_rebel_on_foot = self
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
	velocity = velocity.normalized() * G.foot_config_walk_speed
	
	if Input.is_action_just_released('mount_moped'):
		S.emit_signal0(S.SIGNAL_REBEL_MOUNT_MOPED)
	
	move_and_slide(velocity)

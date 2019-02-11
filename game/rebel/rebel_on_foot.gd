extends KinematicBody2D

var velocity = Vector2()
var dissing_zone_node

func disable():
	set_physics_process(false)
	visible = false
	
func enable():
	set_physics_process(true)
	visible = true

func _ready():
	G.node_rebel_on_foot = self
	dissing_zone_node = $dissing_zone
	dissing_zone_node.hide()
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
		
	if Input.is_action_pressed('flip_bird'):
		if (not dissing_zone_node.is_visible_in_tree()):
			dissing_zone_node.show()
	else :
		if (dissing_zone_node.is_visible_in_tree()):
			dissing_zone_node.hide()
	
	var collision = move_and_collide(velocity * delta)

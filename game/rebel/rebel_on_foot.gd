extends KinematicBody2D


var velocity = Vector2(25, 25)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _physics_process(delta):
	move_and_slide(velocity)
	F.logf("on floor: %s | on wall: %s | on ceiling: %s", [
		is_on_floor(),
		is_on_wall(),
		is_on_ceiling()
	])

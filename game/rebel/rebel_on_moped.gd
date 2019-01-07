extends KinematicBody2D


var velocity = Vector2()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func _physics_process(delta):

	move_and_slide(velocity)

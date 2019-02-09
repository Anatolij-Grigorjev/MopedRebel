extends KinematicBody2D

var sprite

var walk_speed = 25

func _ready():
	add_to_group(C.GROUP_CITIZENS)
	sprite = $sprite
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func enter_diss_zone():
	var rebel_position = G.node_active_rebel.global_position
	var rebel_direction = (rebel_position - global_position).normalize()
	#TODO: run or fight?
	pass

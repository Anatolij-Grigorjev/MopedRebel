extends KinematicBody2D

var sprite
var should_move = false
var velocity = Vector2()
var walk_speed = 25

func _ready():
	add_to_group(C.GROUP_CITIZENS)
	sprite = $sprite
	pass

func _process(delta):
	if (should_move):
		var collision = move_and_collide(velocity * delta)
		if (collision):
			print("citizen got collision!")
	pass

func enter_diss_zone():
	var rebel_position = G.node_active_rebel.global_position
	var rebel_direction = (rebel_position - global_position).normalized()
	
	_prepare_aggressive_response(rebel_direction)
	pass


func _prepare_aggressive_response(rebel_direction):
	velocity = walk_speed * rebel_direction
	should_move = true
	set_collision_mask_bit(C.LAYERS_REBEL_SIDEWALK, true)
	
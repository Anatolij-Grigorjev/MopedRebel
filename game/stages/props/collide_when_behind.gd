extends StaticBody2D

var max_collide_y
var collider

func _ready():
	collider = $collider
	max_collide_y = collider.global_position.y
	pass

func _process(delta):
	
	if (F.is_rebel_on_sidewalk()):
		collider.disabled = max_collide_y < G.node_active_rebel.low_position.global_position.y
	

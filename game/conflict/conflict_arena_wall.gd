extends StaticBody2D

export(float) var fadein_start_distance = 250

func _ready():
	pass
	
func _process(delta):
	var distance_to_rebel = global_position.distance_to(G.node_active_rebel.global_position)
	if (distance_to_rebel < fadein_start_distance):
		modulate.a = 1 - distance_to_rebel / fadein_start_distance
	else:
		modulate.a = 0
